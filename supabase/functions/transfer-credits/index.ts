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
    const { delivery_id } = await req.json()

    if (!delivery_id) {
      return new Response(
        JSON.stringify({ error: 'delivery_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Fetch delivery
    const { data: delivery, error: deliveryError } = await supabase
      .from('deliveries')
      .select('id, requester_id, runner_id, credit_cost, status, confirmed_at')
      .eq('id', delivery_id)
      .single()

    if (deliveryError || !delivery) {
      return new Response(
        JSON.stringify({ error: 'Delivery not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (delivery.confirmed_at) {
      return new Response(
        JSON.stringify({ message: 'Already confirmed' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (delivery.status !== 'delivered') {
      return new Response(
        JSON.stringify({ error: 'Delivery must be in delivered status' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!delivery.runner_id) {
      return new Response(
        JSON.stringify({ error: 'No runner assigned' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Fetch both profiles
    const [{ data: runner }, { data: requester }] = await Promise.all([
      supabase
        .from('profiles')
        .select('tomato_credits, reliability, streak_days')
        .eq('id', delivery.runner_id)
        .single(),
      supabase
        .from('profiles')
        .select('tomato_credits')
        .eq('id', delivery.requester_id)
        .single(),
    ])

    if (!runner || !requester) {
      return new Response(
        JSON.stringify({ error: 'Could not load user profiles' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (requester.tomato_credits < delivery.credit_cost) {
      return new Response(
        JSON.stringify({ error: 'Requester has insufficient credits' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Deduct from requester
    await supabase
      .from('profiles')
      .update({ tomato_credits: requester.tomato_credits - delivery.credit_cost })
      .eq('id', delivery.requester_id)

    // Pay runner and update stats
    await supabase
      .from('profiles')
      .update({
        tomato_credits: runner.tomato_credits + delivery.credit_cost,
        reliability: Math.min(1.0, runner.reliability + 0.002),
        streak_days: runner.streak_days + 1,
      })
      .eq('id', delivery.runner_id)

    // Record transaction
    await supabase.from('credit_transactions').insert({
      from_user_id: delivery.requester_id,
      to_user_id: delivery.runner_id,
      amount: delivery.credit_cost,
      type: 'earn',
      reference_id: delivery_id,
    })

    // Mark delivery confirmed
    await supabase
      .from('deliveries')
      .update({ confirmed_at: new Date().toISOString(), status: 'delivered' })
      .eq('id', delivery_id)

    // Notify runner
    await supabase.from('notifications').insert({
      user_id: delivery.runner_id,
      title: 'Credits received',
      body: `You earned ${delivery.credit_cost} tomato credits for completing a delivery.`,
      type: 'credit',
    })

    // Notify requester
    await supabase.from('notifications').insert({
      user_id: delivery.requester_id,
      title: 'Delivery confirmed',
      body: 'Your delivery has been confirmed. Thanks for using Tomato!',
      type: 'delivery',
    })

    return new Response(
      JSON.stringify({ message: 'Credits transferred', amount: delivery.credit_cost }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
