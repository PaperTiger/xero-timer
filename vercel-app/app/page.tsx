"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"

export default function Home() {
  const [isLoading, setIsLoading] = useState(false)

  const handleConnect = async () => {
    setIsLoading(true)
    try {
      const response = await fetch("/api/auth/xero")
      const data = await response.json()
      window.location.href = data.url
    } catch (error) {
      console.error("Failed to initiate Xero auth:", error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="container flex items-center justify-center min-h-screen py-12">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl">Xero OAuth Authentication</CardTitle>
          <CardDescription>Connect your desktop application to Xero</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col items-center">
          <Button className="w-full" size="lg" onClick={handleConnect} disabled={isLoading}>
            {isLoading ? "Connecting..." : "Connect to Xero"}
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}

