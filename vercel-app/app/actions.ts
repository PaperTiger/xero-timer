"use server"

import { cookies } from "next/headers"
import { v4 as uuidv4 } from "uuid"
import { createHash, randomBytes } from "crypto"

// Xero OAuth endpoints
const XERO_AUTHORIZATION_URL = "https://login.xero.com/identity/connect/authorize"
const XERO_TOKEN_URL = "https://identity.xero.com/connect/token"

// Get these from your environment variables
const getClientId = () => process.env.XERO_CLIENT_ID
const getClientSecret = () => process.env.XERO_CLIENT_SECRET
const getRedirectUri = () =>
  process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}/callback` : "http://localhost:3000/callback"

function generateCodeVerifier() {
  return randomBytes(32).toString("base64url")
}

function generateCodeChallenge(verifier: string) {
  return createHash("sha256").update(verifier).digest("base64url")
}

export async function initiateXeroAuth() {
  const clientId = getClientId()

  if (!clientId) {
    throw new Error("Xero client ID is not configured")
  }

  // Generate and store state for CSRF protection
  const state = uuidv4()

  // Generate code verifier and challenge for PKCE
  const codeVerifier = generateCodeVerifier()
  const codeChallenge = generateCodeChallenge(codeVerifier)

  cookies().set("xero_oauth_state", state, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    maxAge: 60 * 10, // 10 minutes
    path: "/",
  })

  // Store code verifier in a cookie
  cookies().set("xero_code_verifier", codeVerifier, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    maxAge: 60 * 10, // 10 minutes
    path: "/",
  })

  // Build authorization URL
  const authUrl = new URL(XERO_AUTHORIZATION_URL)
  authUrl.searchParams.append("response_type", "code")
  authUrl.searchParams.append("client_id", clientId)
  authUrl.searchParams.append("redirect_uri", getRedirectUri())
  authUrl.searchParams.append(
    "scope",
    "offline_access accounting.transactions accounting.settings accounting.contacts projects.read.all projects.read projects.write timesheets.read timesheets.write",
  )
  authUrl.searchParams.append("state", state)
  authUrl.searchParams.append("code_challenge", codeChallenge)
  authUrl.searchParams.append("code_challenge_method", "S256")

  // Return the authorization URL
  return authUrl.toString()
}

export async function exchangeCodeForToken(code: string, state: string | null) {
  const clientId = getClientId()
  const clientSecret = getClientSecret()

  if (!clientId || !clientSecret) {
    throw new Error("Xero credentials are not configured")
  }

  // Verify state to prevent CSRF attacks
  const storedState = cookies().get("xero_oauth_state")?.value

  if (!storedState || storedState !== state) {
    throw new Error("Invalid state parameter")
  }

  // Get the code verifier
  const codeVerifier = cookies().get("xero_code_verifier")?.value

  if (!codeVerifier) {
    throw new Error("Code verifier not found")
  }

  // Clear the state and code verifier cookies
  cookies().set("xero_oauth_state", "", { maxAge: 0, path: "/" })
  cookies().set("xero_code_verifier", "", { maxAge: 0, path: "/" })

  // Exchange code for token
  const tokenResponse = await fetch(XERO_TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Authorization: `Basic ${Buffer.from(`${clientId}:${clientSecret}`).toString("base64")}`,
    },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      code,
      redirect_uri: getRedirectUri(),
      code_verifier: codeVerifier,
    }),
  })

  if (!tokenResponse.ok) {
    const errorData = await tokenResponse.text()
    console.error("Token exchange failed:", errorData)
    throw new Error(`Failed to exchange code for token: ${tokenResponse.status}`)
  }

  return tokenResponse.json()
}

