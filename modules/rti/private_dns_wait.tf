# Waits for the RTI SQL Server's own private endpoint DNS record and TCP
# connectivity to be ready before the SQL user-bootstrap script connects to it
# over the private link. The shared private DNS zone, VNet links, and VNet
# peering are already established by modules/service — only this new private
# endpoint's own record needs to propagate.
resource "null_resource" "wait_for_rti_sql_private_dns" {
  count = var.configure_private_endpoints ? 1 : 0

  triggers = {
    fqdn                = "${var.rti_sql_server_name}${local.sql_server_suffix}"
    port                = "1433"
    private_endpoint_id = azurerm_private_endpoint.rti_sql_server[0].id
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = "& '${path.module}/scripts/wait-for-private-endpoint.ps1' -Fqdn '${self.triggers.fqdn}' -Port ${self.triggers.port} -MaxAttempts 60 -DelaySeconds 10 -PostResolveDelaySeconds ${var.private_endpoint_post_resolve_delay}"
  }

  depends_on = [
    azurerm_private_endpoint.rti_sql_server,
  ]
}
