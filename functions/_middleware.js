// functions/_middleware.js
export async function onRequest(context) {
  const { request, env, next } = context;
  const pwd = env.BOLT_PASSWORD;
  if (!pwd) {
    return new Response("🔒 BOLT_PASSWORD não definido", { status: 500 });
  }
  const auth = request.headers.get("authorization") || "";
  const [scheme, credentials] = auth.split(" ");
  const expected = btoa(`:${pwd}`);
  if (scheme !== "Basic" || credentials !== expected) {
    return new Response("Autenticação necessária", {
      status: 401,
      headers: { "WWW-Authenticate": `Basic realm="Bolt.diy"` },
    });
  }
  return next();
}
