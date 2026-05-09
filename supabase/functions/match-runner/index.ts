import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

async function sendFCMNotification(token: string, title: string, body: string, data: Record<string, string>) {
  const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY') ?? ''

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify({
      to: token,
      notification: { title, body, sound: 'default' },
      data,
      priority: 'high',
    }),
  })

  return response.ok
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { delivery_id, requester_id } = await req.json()

    if (!delivery_id || !requester_id) {
      return new Response(
        JSON.stringify({ error: 'delivery_id and requester_id required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Update delivery status to matching
    await supabase
      .from('deliveries')
      .update({ status: 'matching' })
      .eq('id', delivery_id)

    // Get delivery details for notification
    const { data: delivery } = await supabase
      .from('deliveries')
      .select('pickup_location, dropoff_location, item_size, credit_cost')
      .eq('id', delivery_id)
      .single()

    // Get all active runners (excluding requester)
    const { data: runners, error } = await supabase
      .from('profiles')
      .select('id, display_name, fcm_token')
      .eq('runner_active', true)
      .neq('id', requester_id)

    if (error) throw error

    let notified = 0
    const notificationPromises = (runners ?? []).map(async (runner) => {
      // Always insert notification in DB
      await supabase.from('notifications').insert({
        user_id: runner.id,
        title: 'New delivery nearby 🍅',
        body: `${delivery?.pickup_location} → ${delivery?.dropoff_location} · ${delivery?.credit_cost} tomatos`,
        type: 'match',
      })

      // Send FCM push if token exists
      if (runner.fcm_token) {
        const sent = await sendFCMNotification(
          runner.fcm_token,
          'New delivery nearby 🍅',
          `${delivery?.pickup_location} → ${delivery?.dropoff_location} · ${delivery?.credit_cost} tomatos`,
          { delivery_id, type: 'new_request' }
        )
        if (sent) notified++
      }
    })

    await Promise.all(notificationPromises)

    // Schedule auto-cancel after 5 minutes if no runner expresses interest
    // This is handled by the auto-confirm edge function or a pg_cron job

    return new Response(
      JSON.stringify({ runners_notified: notified, total_runners: runners?.length ?? 0 }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
