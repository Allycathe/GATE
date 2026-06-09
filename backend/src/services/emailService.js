const { Resend } = require('resend');
const resend = new Resend(process.env.RESEND_API_KEY);

async function sendPasswordResetEmail(toEmail, resetToken) {
  const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

  const response = await resend.emails.send({
    from: 'onboarding@resend.dev',
    to: 'alonso.iturra@mail.udp.cl', // tu email registrado en Resend
    subject: 'Recuperación de contraseña - GATE',
    html: `
      <div style="font-family: sans-serif; max-width: 480px; margin: auto;">
        <h2>Recuperar contraseña</h2>
        <p>Recibimos una solicitud para restablecer tu contraseña.</p>
        <a href="${resetUrl}" 
           style="display:inline-block; padding:12px 24px; background:#1a1a1a; color:white; 
                  text-decoration:none; border-radius:6px; margin:16px 0;">
          Restablecer contraseña
        </a>
        <p style="color:#666; font-size:13px;">Si no solicitaste esto, ignora este correo.</p>
      </div>
    `,
  });

  console.log('[Resend] respuesta:', JSON.stringify(response));
}

module.exports = { sendPasswordResetEmail };
