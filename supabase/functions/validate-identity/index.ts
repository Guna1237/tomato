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
    const body = await req.json()
    const { user_id, email, display_name, roll_number, photo_path, face_confidence } = body

    if (!user_id || !email) {
      return new Response(
        JSON.stringify({ error: 'user_id and email are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const DOMAIN = 'mahindrauniversity.edu.in'
    const emailLower = email.toLowerCase()
    const parts = emailLower.split('@')

    if (parts.length !== 2 || parts[1] !== DOMAIN) {
      return new Response(
        JSON.stringify({ error: 'Email must be a Mahindra University address' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const prefix = parts[0]
    const studentRegex = /^[a-z]{2}\d{2}[a-z]{4}\d{3}$/

    // Determine role from email prefix
    let role = 'student'
    let detectedRollNumber: string | null = null

    if (studentRegex.test(prefix)) {
      role = 'student'
      detectedRollNumber = roll_number || prefix.toUpperCase()
    } else {
      // Faculty or other — still allow signup
      role = 'faculty'
    }

    // Determine face_status from confidence sent by client ML Kit
    const confidence = typeof face_confidence === 'number' ? face_confidence : 0
    const faceStatus = confidence >= 0.65 ? 'approved' : 'pending'

    // Build photo_url if photo was uploaded
    let photoUrl: string | null = null
    if (photo_path) {
      const { data } = supabase.storage.from('profile-photos').getPublicUrl(photo_path)
      photoUrl = data?.publicUrl ?? null
    }

    // Use provided display_name or fall back to email prefix
    const name = display_name?.trim() || prefix.toUpperCase()

    // Upsert profile — handles both new users and re-runs after partial failure
    const { error: profileError } = await supabase
      .from('profiles')
      .upsert({
        id: user_id,
        email: emailLower,
        role,
        display_name: name,
        roll_number: detectedRollNumber,
        photo_url: photoUrl,
        face_status: faceStatus,
        face_confidence: confidence,
        tomato_credits: 50,
      }, { onConflict: 'id', ignoreDuplicates: false })

    if (profileError) throw profileError

    // Signup bonus — only insert if no prior transactions for this user
    const { count } = await supabase
      .from('credit_transactions')
      .select('id', { count: 'exact', head: true })
      .eq('to_user_id', user_id)
      .eq('type', 'signup')

    if (!count || count === 0) {
      await supabase.from('credit_transactions').insert({
        to_user_id: user_id,
        amount: 50,
        type: 'signup',
      })

      await supabase.from('notifications').insert({
        user_id,
        title: 'Welcome to Tomato',
        body: 'You received 50 tomato credits to get started!',
        type: 'system',
      })
    }

    return new Response(
      JSON.stringify({
        role,
        roll_number: detectedRollNumber,
        display_name: name,
        face_status: faceStatus,
        message: 'Profile created',
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
