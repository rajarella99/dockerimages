# #!/bin/bash

# auth=$(echo -n "pat:6rerzuhqzwfm5hmdl47g56wc3dd4gyuz4ddwc2jxuowgrintoytq" | base64)
# wget -O otel-contrib-collector_0.43.0_amd64.deb "https://wkaxcess.visualstudio.com/012183aa-ad17-44cb-aeab-d675e3d36524/_apis/git/repositories/5a48b471-c158-4bf0-a519-36da01e78829/items?path=/Deployments/otel-contrib-collector_0.43.0_amd64.deb&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=main&resolveLfs=true&%24format=octetStream&api-version=5.0&download=true" --header "Authorization: Basic $auth" -P /telemetry


#!/bin/bash

auth=$(echo -n "pat:6rerzuhqzwfm5hmdl47g56wc3dd4gyuz4ddwc2jxuowgrintoytq" | base64)
wget -O otel-contrib-collector_0.66.0_amd64.deb "https://wkaxcess.visualstudio.com/012183aa-ad17-44cb-aeab-d675e3d36524/_apis/git/repositories/5a48b471-c158-4bf0-a519-36da01e78829/items?path=/Deployments/otel-contrib-collector_0.66.0_amd64.deb&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=main&resolveLfs=true&%24format=octetStream&api-version=5.0&download=true" --header "Authorization: Basic $auth" -P /telemetry