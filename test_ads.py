#!/usr/bin/env python3

import argparse
import pyads


def test_connection(ip, ams_net_id, ads_port):
    print(f"\nTesting ADS port {ads_port}...")

    try:
        with pyads.Connection(ams_net_id, ads_port, ip) as plc:
            print("  TCP/ADS connection opened")

            state = plc.read_state()
            print(f"  SUCCESS: ADS state = {state}")
            return True

    except Exception as exc:
        print(f"  FAILED: {exc}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Test conventional (non-secure) ADS connectivity"
    )
    parser.add_argument("ip", help="Beckhoff IPv4 address")
    parser.add_argument("ams", help="Beckhoff AMS Net ID")
    parser.add_argument("local_ams", help="Local IOC AMS Net ID")
    args = parser.parse_args()

    # Configure local AMS identity to match the route on the Beckhoff
    pyads.open_port()
    pyads.set_local_address(args.local_ams)

    try:
        results = {
            10000: test_connection(args.ip, args.ams, 10000),
            851: test_connection(args.ip, args.ams, 851),
        }
    finally:
        pyads.close_port()

    print("\n--- Results ---")
    for port, success in results.items():
        print(f"ADS port {port}: {'OK' if success else 'FAILED'}")


if __name__ == "__main__":
    main()
    
