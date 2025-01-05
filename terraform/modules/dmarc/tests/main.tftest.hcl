run "no_inputs" {
  command = apply

  variables {}

  assert {
    condition     = output.dmarc_record == "v=DMARC1;p=none;"
    error_message = "Incorrect DMARC"
  }
}

run "all_inputs" {
  command = apply

  variables {
    percentage             = 20
    forensic_report_email  = "f@test.com"
    aggregate_report_email = "a@test.com"
    policy                 = "quarantine"
    subdomain_policy       = "reject"
    dkim_alignment_mode    = "r"
    spf_alignment_mode     = "s"
  }

  assert {
    condition     = output.dmarc_record == "v=DMARC1;pct=20;ruf=mailto:f@test.com;rua=mailto:a@test.com;p=quarantine;sp=reject;adkim=r;aspf=s;"
    error_message = "Incorrect DMARC"
  }
}
