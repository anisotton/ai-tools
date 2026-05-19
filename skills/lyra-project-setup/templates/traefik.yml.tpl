http:
  routers:
    {{SLUG}}:
      rule: "Host(`{{SLUG}}.lyra`)"
      entryPoints:
        - websecure
      service: {{SLUG}}
      tls: {}
  services:
    {{SLUG}}:
      loadBalancer:
        servers:
          - url: "http://{{SLUG}}-app:{{APP_PORT}}"
