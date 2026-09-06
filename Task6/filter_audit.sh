#!/bin/bash

INPUT="audit.log"
OUTPUT="audit_extract.json"

jq -s '
[
  .[]
  | select(
      (
        .objectRef.resource == "secrets"
        and (.verb == "get" or .verb == "list")
      )

      or

      (
        (.verb == "create" or .verb == "get")
        and .objectRef.subresource == "exec"
      )

      or

      (
        .objectRef.resource == "pods"
        and any(
          .requestObject.spec.containers[]?;
          .securityContext.privileged == true
        )
      )

      or

      (
        .objectRef.resource == "rolebindings"
        and .objectRef.name == "escalate-binding"
      )

      or

      (.verb == "delete" or .verb == "update" or .verb == "patch")
      and (
      ((.requestURI // "") | test("audit-policy"; "i"))
        or
      ((.objectRef.name // "") | test("audit-policy"; "i"))
      )
    )
]
' "$INPUT" > "$OUTPUT"

echo "Suspicious events saved to $OUTPUT"