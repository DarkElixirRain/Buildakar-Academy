// templates/verificationEmail.ts

export function verificationTemplate(code: string) {
    return `
    <div style="font-family:Arial">

        <h2>Verify your Email</h2>

        <p>Your verification code is</p>

        <h1>${code}</h1>

        <p>This code expires in 10 minutes.</p>

    </div>
    `;
}