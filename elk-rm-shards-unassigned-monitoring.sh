
# Fix issue when cluster is stuck at:
#   'Elasticsearch is still initializing the Monitoring indices'
# Delete .monitoring-* indices with unassigned shards
# But cluster is likely out of disk space

elk_gtwy=$1

unassigned_before=$(curl -s -XGET http://${elk_gtwy}:9200/_cat/shards | grep UNASSIGNED \
  | awk '{ print $1 }' | wc -l)
# Delete .monitoring-* indices with unassigned shards
for index in $(curl -s -XGET http://${elk_gtwy}:9200/_cat/shards | grep UNASSIGNED \
  | grep .monitoring- | awk '{ print $1 }' | sort -u); do
    curl -XDELETE "${elk_gtwy}:9200/${index}?pretty"
done
unassigned_after=$(curl -s -XGET http://${elk_gtwy}:9200/_cat/shards | grep UNASSIGNED \
  | awk '{ print $1 }' | wc -l)

echo "Shards unassigned before monitoring cleanup: ${unassigned_before}"
echo "Shards unassigned after monitoring cleanup : ${unassigned_after}"
