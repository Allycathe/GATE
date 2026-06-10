const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp-relay.brevo.com',
  port: 587,
  auth: {
    user: process.env.BREVO_USER, // tu email de cuenta Brevo
    pass: process.env.BREVO_SMTP_KEY, // SMTP key de Brevo (distinta a la API key)
  },
});

async function sendPasswordResetEmail(toEmail, resetToken) {
  await transporter.sendMail({
    from: '"GATE" <' + process.env.BREVO_SENDER + '>',
    to: toEmail,
    subject: 'Recuperación de contraseña - GATE',
    html: `
      <div style="font-family: sans-serif; max-width: 480px; margin: auto;">
        <h2>Recuperar contraseña</h2>
        <p>Tu código de verificación es:</p>
        <h1 style="letter-spacing: 8px; font-size: 40px; text-align:center; 
                   background:#f4f4f4; padding: 20px; border-radius: 8px;">
          ${resetToken}
        </h1>
        <p style="color:#666; font-size:13px;">
          Expira en 15 minutos. Si no solicitaste esto, ignora este correo.
        </p>
      </div>
    `,
  });
  console.log('[Brevo] Código enviado a:', toEmail);
}

module.exports = { sendPasswordResetEmail };