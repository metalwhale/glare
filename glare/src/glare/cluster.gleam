import gleam/function
import gleam/io
import gleam/list
import gleam/option
import gleam/string

import gleam/erlang/atom
import gleam/erlang/node
import gleam/erlang/process
import gleam/otp/actor

pub opaque type Cluster {
  Cluster(peer_node_name: String)
}

pub opaque type ClusterMessage {
  Connect
}

type ClusterState {
  ClusterState(subject: process.Subject(ClusterMessage), cluster: Cluster)
}

pub fn new(peer_node_name: String) -> Cluster {
  Cluster(peer_node_name: peer_node_name)
}

pub fn start(
  cluster: Cluster,
) -> Result(process.Subject(ClusterMessage), actor.StartError) {
  actor.start_spec(create_spec(cluster))
}

fn create_spec(cluster: Cluster) -> actor.Spec(ClusterState, ClusterMessage) {
  actor.Spec(
    init: fn() -> actor.InitResult(ClusterState, ClusterMessage) {
      let node_name = node.self() |> node.to_atom |> atom.to_string
      io.println("Current node name: '" <> node_name <> "'.")
      let state = ClusterState(subject: process.new_subject(), cluster: cluster)
      process.send(state.subject, Connect)
      actor.Ready(
        state,
        process.new_selector()
          |> process.selecting(state.subject, function.identity),
      )
    },
    init_timeout: 1000,
    loop: fn(message: ClusterMessage, state: ClusterState) -> actor.Next(
      ClusterMessage,
      ClusterState,
    ) {
      case message {
        Connect -> {
          let peer_node_name = state.cluster.peer_node_name
          io.println("Connecting to a peer node: '" <> peer_node_name <> "'...")
          case node.connect(atom.create_from_string(peer_node_name)) {
            Error(_) -> {
              process.sleep(2000)
              process.send(state.subject, Connect)
              actor.Continue(state, option.None)
            }
            Ok(_) -> {
              let peer_node_names =
                node.visible()
                |> list.map(fn(n) { n |> node.to_atom |> atom.to_string })
                |> list.map(fn(n) { "'" <> n <> "'" })
                |> string.join(", ")
              io.println(
                "List of connected peer nodes: " <> peer_node_names <> ".",
              )
              actor.Stop(process.Normal)
            }
          }
        }
      }
    },
  )
}
