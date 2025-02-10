import envoy
import gleam/erlang/process

import glare/cluster

pub fn main() {
  let assert Ok(peer_node_name) = envoy.get("GLARE_PEER_NODE_NAME")
  let assert Ok(_) = cluster.start(cluster.new(peer_node_name))
  process.sleep_forever()
}
