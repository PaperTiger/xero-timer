"use client"

import { useEffect, useState } from "react"
import { useSearchParams } from "next/navigation"
import { exchangeCodeForToken } from "@/app/actions"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { CheckCircle, Copy, XCircle } from "lucide-react"

export default function CallbackPage() {
  const searchParams = useSearchParams()
  const code = searchParams.get("code")
  const state = searchParams.get("state")
  const error = searchParams.get("error")

  const [status, setStatus] = useState<"loading" | "success" | "error">("loading")
  const [tokenData, setTokenData] = useState<any>(null)
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    if (error) {
      setStatus("error")
      return
    }

    if (code) {
      exchangeCodeForToken(code, state)
        .then((data) => {
          setTokenData(data)
          setStatus("success")

          // Redirect to the desktop app
          const redirectUrl = `xerotimer://oauth/callback?${new URLSearchParams(data)}`
          window.location.href = redirectUrl
        })
        .catch((err) => {
          console.error("Error exchanging code for token", err)
          setStatus("error")
        })
    }
  }, [code, state, error])

  const copyToClipboard = () => {
    if (tokenData) {
      navigator.clipboard.writeText(JSON.stringify(tokenData, null, 2))
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  return (
    <div className="container flex items-center justify-center min-h-screen py-12">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>
            Authentication {status === "loading" ? "in progress" : status === "success" ? "successful" : "failed"}
          </CardTitle>
          <CardDescription>
            {status === "loading"
              ? "Processing your Xero authentication..."
              : status === "success"
                ? "You have successfully connected to Xero"
                : "There was a problem connecting to Xero"}
          </CardDescription>
        </CardHeader>
        <CardContent>
          {status === "loading" && (
            <div className="flex justify-center py-4">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
          )}

          {status === "success" && (
            <Alert className="bg-green-50 border-green-200">
              <CheckCircle className="h-4 w-4 text-green-600" />
              <AlertTitle>Success!</AlertTitle>
              <AlertDescription>
                Redirecting you back to the XeroTimer app. If the app doesn't open automatically, please click the
                button below or copy the tokens manually.
              </AlertDescription>
            </Alert>
          )}

          {status === "error" && (
            <Alert className="bg-red-50 border-red-200">
              <XCircle className="h-4 w-4 text-red-600" />
              <AlertTitle>Authentication Failed</AlertTitle>
              <AlertDescription>
                {error || "There was an error during the authentication process. Please try again."}
              </AlertDescription>
            </Alert>
          )}

          {status === "success" && tokenData && (
            <div className="mt-4">
              <Button
                className="w-full mb-4"
                onClick={() => {
                  const redirectUrl = `xerotimer://oauth/callback?${new URLSearchParams(tokenData)}`
                  window.location.href = redirectUrl
                }}
              >
                Open XeroTimer App
              </Button>
              <div className="relative mt-2">
                <pre className="bg-muted p-4 rounded-md overflow-auto text-xs max-h-40">
                  {JSON.stringify(tokenData, null, 2)}
                </pre>
                <Button size="sm" variant="ghost" className="absolute top-2 right-2" onClick={copyToClipboard}>
                  {copied ? <CheckCircle className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                </Button>
              </div>
            </div>
          )}
        </CardContent>
        <CardFooter className="flex justify-center">
          {status === "error" && <Button onClick={() => (window.location.href = "/")}>Try Again</Button>}
        </CardFooter>
      </Card>
    </div>
  )
}

