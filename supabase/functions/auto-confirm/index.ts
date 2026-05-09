import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

    // Find deliveries delivered > 10 minutes ago with no confirmation
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000).toISOString()

    const { data: pendingConfirms, error } = await supabase
      .from('deliveries')
      .select('id')
      .eq('status', 'delivered')
      .is('confirmed_at', null)
      .lt('delivered_at', tenMinutesAgo)

    if (error) throw error

    let confirmed = 0
    for (const delivery of (pendingConfirms ?? [])) {
      // Call transfer-credits for each
      const res = await fetch(`${supabaseUrl}/functions/v1/transfer-credits`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${serviceKey}`,
        },
        body: JSON.stringify({ delivery_id: delivery.id }),
      })

      if (res.ok) confirmed++
    }

    // Also cancel deliveries in 'matching' status with no runner interest after 5 minutes
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString()

    const { data: expiredMatching } = await supabase
      .from('deliveries')
      .select('id, requester_id, credit_cost')
      .eq('status', 'matching')
      .lt('created_at', fiveMinutesAgo)

    let cancelled = 0
    for (const delivery of (expiredMatching ?? [])) {
      // Check if any runner expressed interest
      const { data: interests } = await supabase
        .from('runner_interests')
        .select('id')
        .eq('delivery_id', delivery.id)
        .limit(1)

      if (!interests || interests.length === 0) {
        // No interest — cancel and refund
        await supabase
          .from('deliveries')
          .update({ status: 'cancelled' })
          .eq('id', delivery.id)

        // Refund requester
        const { data: requester } = await supabase
          .from('profiles')
          .select('tomato_credits')
          .eq('id', delivery.requester_id)
          .single()

        if (requester) {
          await supabase
            .from('profiles')
            .update({ tomato_credits: requester.tomato_credits + delivery.credit_cost })
            .eq('id', delivery.requester_id)

          await supabase.from('credit_transactions').insert({
            to_user_id: delivery.requester_id,
            amount: delivery.credit_cost,
            type: 'refund',
            reference_id: delivery.id,
          })

          await supabase.from('notifications').insert({
            user_id: delivery.requester_id,
            title: 'No runners available',
            body: `Your request was cancelled. ${delivery.credit_cost} tomatos refunded.`,
            type: 'system',
          })
        }

        cancelled++
      }
    }

    return new Response(
      JSON.stringify({ confirmed, cancelled }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
