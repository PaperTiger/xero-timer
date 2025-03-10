import { initiateXeroAuth } from "@/app/actions"
import { NextResponse } from "next/server"

export async function GET() {
  const authUrl = await initiateXeroAuth()
  return NextResponse.json({ url: authUrl })
}

