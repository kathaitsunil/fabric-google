# --- CRITICAL STABILIZATION SENTINEL ---
# If you see the bucket deletion error instead of this message, your TFC workspace is DISCONNECTED.
resource "terraform_data" "DIAGNOSTIC_SYNC_TEST" {
  lifecycle {
    precondition {
      condition     = false
      error_message = "!!! VERIFIED: TFC IS READING NEW FILES !!!"
    }
  }
}
