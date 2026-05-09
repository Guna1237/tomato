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
    const { user_id, email, employee_id } = await req.json()

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
    const facultyRegex = /^[a-z]+\.[a-z]+$/

    let role: string
    let rollNumber: string | null = null
    let displayName: string

    if (studentRegex.test(prefix)) {
      role = 'student'
      rollNumber = prefix
      displayName = prefix.toUpperCase()
    } else if (facultyRegex.test(prefix)) {
      role = 'faculty'
      const nameParts = prefix.split('.')
      displayName = nameParts.map((p: string) => p.charAt(0).toUpperCase() + p.slice(1)).join(' ')

      if (!employee_id) {
        return new Response(
          JSON.stringify({ error: 'Employee ID required for faculty' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const { data: facultyRecord, error: registryError } = await supabase
        .from('faculty_registry')
        .select('id')
        .eq('email', emailLower)
        .eq('employee_id', employee_id)
        .single()

      if (registryError || !facultyRecord) {
        return new Response(
          JSON.stringify({ error: 'Employee ID does not match our records. Contact admin.' }),
          { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    } else {
      return new Response(
        JSON.stringify({ error: 'Email format not recognized as student or faculty' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Insert profile
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        id: user_id,
        email: emailLower,
        role,
        display_name: displayName,
        roll_number: rollNumber,
        employee_id: role === 'faculty' ? employee_id : null,
        face_status: 'pending',
        tomato_credits: 50,
      })

    if (profileError && profileError.code !== '23505') { // ignore duplicate
      throw profileError
    }

    // Insert signup bonus transaction
    await supabase.from('credit_transactions').insert({
      to_user_id: user_id,
      amount: 50,
      type: 'signup',
    })

    // Insert welcome notification
    await supabase.from('notifications').insert({
      user_id,
      title: 'Welcome to Tomato 🍅',
      body: `You received 50 tomato credits to get started!`,
      type: 'system',
    })

    return new Response(
      JSON.stringify({ role, roll_number: rollNumber, display_name: displayName, message: 'Identity verified' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
