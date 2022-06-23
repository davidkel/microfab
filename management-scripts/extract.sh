# execute viper

tmpdir=vipertmp
idname=User1

rm -fr $tmpdir
mkdir $tmpdir

componentData=$(curl -H "Host: console.172.21.0.30.nip.io:8080" http://127.0.0.1:8080/ak/api/v1/components)

cert=$(echo $componentData | jq '.[] | select(.id == "org1admin")' | jq -r '.cert')
key=$(echo $componentData | jq '.[] | select(.id == "org1admin")' | jq -r '.private_key')

echo -e "{\n    \"name\":\"$idname\",\n    \"cert\":\"$cert\",\n    \"private_key\":\"$key\"\n}" > $tmpdir/User1.json

echo $componentData | jq '.[] | select(.type == "gateway")' > $tmpdir/ccp.json