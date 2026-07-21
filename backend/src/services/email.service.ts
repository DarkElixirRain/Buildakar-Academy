
import { resend } from "../lib/resend";
import { verificationTemplate } from "../templates/verificationEmail";

export async function sendVerificationEmail(
    email: string,
    code: string
) {

    if(!email){
        throw new Error("Unauthorized")
    }


   const res = await resend.emails.send({

        from: process.env.EMAIL_FROM!,

        to: email,

        subject: "Verify your email",

        html: verificationTemplate(code),

    });

    console.log(res)

}