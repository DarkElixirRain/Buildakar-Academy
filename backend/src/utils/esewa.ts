import crypto from 'crypto'


interface EsewaStatusResponse {
  status: string;
  transaction_code: string;
  total_amount: string;
  transaction_uuid: string;
  [key: string]: string;
}

export function generateSignature(
  totalAmount: number,
  transactionUuid: string,
  productCode: string,
  secretKey: string
): string {
  const message = `total_amount=${totalAmount},transaction_uuid=${transactionUuid},product_code=${productCode}`;
 
  const signature = crypto
    .createHmac('sha256', secretKey)
    .update(message)
    .digest('base64');
 
  return signature;
}

export function verifyEsewaSignature(data:Record<string,string>,secretKey:string){
try {
      const signedFieldNames = data.signed_field_names;
    if (!signedFieldNames) {
      return false;
    }
    const fields = signedFieldNames.split(',')
    const message = fields.map((field)=>`${field}=${data[field] ?? ""}`).join(",")

     const expectedSignature = crypto
      .createHmac('sha256', secretKey)
      .update(message)
      .digest('base64');

    const receivedSignature = data.signature;
 
    // Use timingSafeEqual to prevent timing attacks
    const expected = Buffer.from(expectedSignature);
    const received = Buffer.from(receivedSignature ?? '');
  if (expected.length !== received.length) {
      return false;
    }
 
    const isValid = crypto.timingSafeEqual(expected, received);
 
    if (!isValid) {
      }
 
    return isValid;
  } catch (error) {
    return false;
 
}
}

// Decodes the base64-encoded response eSewa sends as the `?data=` query param
// on both success and failure redirect URLs.

export function decodeEsewaResponse(encoded: string): Record<string, string> {
  try {
    const decoded = Buffer.from(encoded, 'base64').toString('utf-8');
    const parsed = JSON.parse(decoded);
 
    // Ensure all values are strings for consistent handling
    const normalized: Record<string, string> = {};
    for (const [key, value] of Object.entries(parsed)) {
      normalized[key] = String(value);
    }
 
    return normalized;
  } catch (error) {
    throw new Error(`Failed to decode eSewa response: ${error}`);
  }
}

export function buildEsewaFormPayload(params: {
  amount: number;
  transactionUuid: string;
  merchantCode: string;
  secretKey: string;
  successUrl: string;
  failureUrl: string;
}): Record<string, string> {
  const {
    amount,
    transactionUuid,
    merchantCode,
    secretKey,
    successUrl,
    failureUrl,
  } = params;
 
  // eSewa v2 requires these exact field names
  // tax, service charge, and delivery charge are 0 for digital products
  const taxAmount = 0;
  const productServiceCharge = 0;
  const productDeliveryCharge = 0;
  const totalAmount = amount + taxAmount + productServiceCharge + productDeliveryCharge;
 
  // eSewa signs exactly these three fields in this exact order
  const signedFieldNames = 'total_amount,transaction_uuid,product_code';
 
  const signature = generateSignature(
    totalAmount,
    transactionUuid,
    merchantCode,
    secretKey
  );
 
  return {
    amount: String(amount),
    tax_amount: String(taxAmount),
    total_amount: String(totalAmount),
    transaction_uuid: transactionUuid,
    product_code: merchantCode,
    product_service_charge: String(productServiceCharge),
    product_delivery_charge: String(productDeliveryCharge),
    success_url: successUrl,
    failure_url: failureUrl,
    signed_field_names: signedFieldNames,
    signature,
  };
}



/**
 * Verifies a payment with eSewa's transaction status API.
 * Always call this after receiving the success redirect —
 * never trust the redirect data alone.
 *
 * Returns the full status response from eSewa.
 */
export async function verifyEsewaPayment(params: {
  baseUrl: string;
  merchantCode: string;
  totalAmount: number;
  transactionUuid: string;
}): Promise<{
  status: string;
  transaction_code: string;
  total_amount: string;
  transaction_uuid: string;
  [key: string]: string;
}> {
  const { baseUrl, merchantCode, totalAmount, transactionUuid } = params;
 
  const url = new URL(`${baseUrl}/api/epay/transaction/status/`);
  url.searchParams.set('product_code', merchantCode);
  url.searchParams.set('total_amount', String(totalAmount));
  url.searchParams.set('transaction_uuid', transactionUuid);
 
  const response = await fetch(url.toString(), {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
  });
 
  if (!response.ok) {
    throw new Error(
      `eSewa status API returned ${response.status}: ${await response.text()}`
    );
  }
 
  const data = await response.json();
 
  return data as EsewaStatusResponse;
}
 