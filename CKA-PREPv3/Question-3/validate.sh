#!/bin/bash
set -euo pipefail

OUTPUT_FILE="/opt/course/3/certificate-info.txt"
CLIENT_CERT="/var/lib/kubelet/pki/kubelet-client-current.pem"
SERVER_CERT="/var/lib/kubelet/pki/kubelet.crt"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

[ -f "$OUTPUT_FILE" ] || fail "Output file $OUTPUT_FILE does not exist"
[ -s "$OUTPUT_FILE" ] || fail "Output file $OUTPUT_FILE is empty"
[ -f "$CLIENT_CERT" ] || fail "Client certificate $CLIENT_CERT does not exist"
[ -f "$SERVER_CERT" ] || fail "Server certificate $SERVER_CERT does not exist"

mapfile -t lines < "$OUTPUT_FILE"
[ "${#lines[@]}" -eq 4 ] || fail "Output file must contain exactly 4 lines"

expected_client_issuer=$(openssl x509 -noout -issuer -in "$CLIENT_CERT" | sed 's/^issuer=//; s/^Issuer: //; s/^ *//')
expected_server_issuer=$(openssl x509 -noout -issuer -in "$SERVER_CERT" | sed 's/^issuer=//; s/^Issuer: //; s/^ *//')

extract_eku() {
  local cert="$1"
  openssl x509 -noout -text -in "$cert" | awk '
    /X509v3 Extended Key Usage/ {getline; gsub(/^ +| +$/, ""); print; exit}
  '
}

expected_client_eku=$(extract_eku "$CLIENT_CERT")
expected_server_eku=$(extract_eku "$SERVER_CERT")

[ -n "$expected_client_issuer" ] || fail "Could not extract expected client issuer"
[ -n "$expected_server_issuer" ] || fail "Could not extract expected server issuer"
[ -n "$expected_client_eku" ] || fail "Could not extract expected client extended key usage"
[ -n "$expected_server_eku" ] || fail "Could not extract expected server extended key usage"

normalize_line() {
  echo "$1" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//'
}

line1=$(normalize_line "${lines[0]}")
line2=$(normalize_line "${lines[1]}")
line3=$(normalize_line "${lines[2]}")
line4=$(normalize_line "${lines[3]}")

expected_line1=$(normalize_line "Issuer: $expected_client_issuer")
expected_line2=$(normalize_line "X509v3 Extended Key Usage: $expected_client_eku")
expected_line3=$(normalize_line "Issuer: $expected_server_issuer")
expected_line4=$(normalize_line "X509v3 Extended Key Usage: $expected_server_eku")

[ "$line1" = "$expected_line1" ] || fail "Line 1 incorrect. Expected: $expected_line1 | Got: $line1"
[ "$line2" = "$expected_line2" ] || fail "Line 2 incorrect. Expected: $expected_line2 | Got: $line2"
[ "$line3" = "$expected_line3" ] || fail "Line 3 incorrect. Expected: $expected_line3 | Got: $line3"
[ "$line4" = "$expected_line4" ] || fail "Line 4 incorrect. Expected: $expected_line4 | Got: $line4"

pass "certificate-info.txt contains the correct issuer and extended key usage values for kubelet client and server certificates"
