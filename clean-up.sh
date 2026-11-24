#!/bin/bash
# =========================================
# 🧹 QWIKLABS QUICK CLEANUP SCRIPT
# I-run lang ni sa dili pa mo-end ang lab!
# =========================================
echo -e "\033[1;34m🧹 Starting resource cleanup...\033[0m"

# 1️⃣ Delete all Compute Engine instances
echo "🔍 Finding VM instances..."
INSTANCES=$(gcloud compute instances list --format="value(name,zone)")
if [ -n "$INSTANCES" ]; then
  echo "$INSTANCES" | while read -r NAME ZONE; do
    echo "🗑️ Deleting instance: $NAME ($ZONE)"
    gcloud compute instances delete "$NAME" --zone="$ZONE" --quiet
  done
else
  echo "✅ No VM instances found"
fi

# 2️⃣ Delete all persistent disks
echo "🔍 Finding persistent disks..."
DISKS=$(gcloud compute disks list --format="value(name,zone)")
if [ -n "$DISKS" ]; then
  echo "$DISKS" | while read -r NAME ZONE; do
    echo "🗑️ Deleting disk: $NAME ($ZONE)"
    gcloud compute disks delete "$NAME" --zone="$ZONE" --quiet
  done
else
  echo "✅ No disks found"
fi

# 3️⃣ Delete Cloud Run services
echo "🔍 Finding Cloud Run services..."
REGIONS=("us-central1" "us-east1" "europe-west1" "asia-southeast1")
for REGION in "${REGIONS[@]}"; do
  SERVICES=$(gcloud run services list --region="$REGION" --platform=managed --format="value(name)" 2>/dev/null)
  if [ -n "$SERVICES" ]; then
    echo "$SERVICES" | while read -r NAME; do
      if [[ "$NAME" != "" ]]; then
        echo "🗑️ Deleting Cloud Run service: $NAME ($REGION)"
        gcloud run services delete "$NAME" --region="$REGION" --platform=managed --quiet
      fi
    done
  fi
done

# 4️⃣ Delete Artifact Registry repos
echo "🔍 Finding Artifact Registry repositories..."
REPOS=$(gcloud artifacts repositories list --format="value(name,location)" 2>/dev/null)
if [ -n "$REPOS" ]; then
  echo "$REPOS" | while read -r NAME LOCATION; do
    echo "🗑️ Deleting repo: $NAME ($LOCATION)"
    gcloud artifacts repositories delete "$NAME" --location="$LOCATION" --quiet
  done
fi

# 5️⃣ Delete Storage Buckets
echo "🔍 Finding Storage Buckets..."
PROJECT_ID=$(gcloud config get-value project)
BUCKETS=$(gsutil ls -p "$PROJECT_ID" 2>/dev/null | grep -q "gs://" && gsutil ls -p "$PROJECT_ID" | grep -v "qwiklabs" || true)
if [ -n "$BUCKETS" ]; then
  echo "$BUCKETS" | while read -r BUCKET; do
    echo "🗑️ Deleting bucket: $BUCKET"
    gsutil rm -r "$BUCKET"
  done
fi

echo -e "\033[1;32m✅ Cleanup complete!\033[0m"
echo -e "\033[1;33m⚠️  Please double-check: https://console.cloud.google.com/developer/resources\033[0m"
