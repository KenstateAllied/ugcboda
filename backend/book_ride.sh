#!/bin/bash

TOKEN=$(curl -s -X POST "http://192.168.62.118:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=passenger1&password=SomeStrongPassword123" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

echo "Token: $TOKEN"

echo "--- Rides ---"
curl -s -X GET "http://192.168.62.118:8000/api/v1/rides" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo "--- Booking ride 1 ---"
curl -s -X POST "http://192.168.62.118:8000/api/v1/rides/1/book" \
  -H "Authorization: Bearer $TOKEN"
