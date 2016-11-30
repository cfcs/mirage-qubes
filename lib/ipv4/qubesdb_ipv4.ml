module Make(D: Qubes.S.DB) (Ethernet : V1_LWT.ETHIF) (Arp : V1_LWT.ARP) = struct
  module IP = Static_ipv4.Make(Ethernet)(Arp)
  include IP
  let connect db ethif arp =
    let (>>=?) ip f = match ip with
      | None -> None
      | Some s -> f s
    in
    let ip = D.read db "/qubes-ip" >>=? Ipaddr.V4.of_string in
    let gateway = D.read db "/qubes-gateway" >>=? Ipaddr.V4.of_string in
    match ip with
    | Some ip ->
      let network = Ipaddr.V4.Prefix.make 32 ip in
      IP.connect ~ip ~network ~gateway ethif arp
    | _ -> Lwt.fail_with "couldn't get ip configuration from qubesdb"
end
