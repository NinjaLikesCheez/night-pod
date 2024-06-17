//
//  MillerShuffle.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 02/04/2024.
//

import Foundation

/*
 unsigned int MillerShuffleAlgo_d(unsigned int inx, unsigned int shuffleID, unsigned int listSize) {
	 unsigned int si, r1, r2, r3, r4, rx, rx2;
	 const unsigned int p1=24317, p2=32141, p3=63629;  // for shuffling 60,000+ indexes

	 shuffleID+=131*(inx/listSize);  // have inx overflow effect the mix
	 si=(inx+shuffleID)%listSize;    // cut the deck

	 r1=shuffleID%p1+42;   // randomizing factors crafted empirically (by automated trial and error)
	 r2=((shuffleID*0x89)^r1)%p2;
	 r3=(r1+r2+p3)%listSize;
	 r4=r1^r2^r3;
	 rx = (shuffleID/listSize) % listSize + 1;
	 rx2 = ((shuffleID/listSize/listSize)) % listSize + 1;

	 // perform conditional multi-faceted mathematical spin-mixing (on avg 2 1/3 shuffle ops done + 2 simple Xors)
	 if (si%3==0) si=(((unsigned long)(si/3)*p1+r1) % ((listSize+2)/3)) *3; // spin multiples of 3
	 if (si%2==0) si=(((unsigned long)(si/2)*p2+r2) % ((listSize+1)/2)) *2; // spin multiples of 2
	 if (si<listSize/2) si=(si*p3+r4) % (listSize/2);

	 if ((si^rx) < listSize)   si ^= rx;			// flip some bits with Xor
	 si = ((unsigned long)si*p3 + r3) % listSize;  // relatively prime gears turning operation
	 if ((si^rx2) < listSize)  si ^= rx2;

	 return(si);  // return 'Shuffled' index
 }
 */

typealias Episodes = [Episode]

struct MillerShuffle {
	let items: Episodes

	private func index(index: Episodes.Index) -> Episodes.Index {
		var si: UInt64
		let r1: UInt64
		let r2: UInt64
		let r3: UInt64
		let r4: UInt64
		let rx: UInt64
		let rx2: UInt64

		let p1: UInt64 = 24317
		let p2: UInt64 = 32141
		let p3: UInt64 = 63629

		let index: UInt64 = 0 // TODO: this should use the startIndex of items - or be provided in the function signature
		let listSize = UInt64(items.count)

		var shuffleID = UInt64.random(in: 0...UInt64.max)
		shuffleID += (131 &* (index / listSize)) // TODO: use the overflow operators to allow for overflow here
		si = (index + shuffleID) % listSize

		r1 = shuffleID % p1 + 42
		r2 = ((shuffleID &* 0x89) ^ r1) % p2
		r3 = (r1 + r2 + p3) % listSize
		r4 = r1 ^ r2 ^ r3
		rx = (shuffleID / listSize) % listSize + 1
		rx2 = ((shuffleID / listSize / listSize) % listSize + 1)

		// perform conditional multi-faceted mathematical spin-mixing (on avg 2 1/3 shuffle ops done + 2 simple Xors)
		if si % 3 == 0 {
			si = ((si / 3) * p1 + r1) % ((listSize + 2) / 3) * 3
		}

		if si % 2 == 0 {
			si = ((si / 2) * p2 + r2) % ((listSize + 1) / 2) * 2
		}

		if si < listSize / 2 {
			si = (si * p3 + r4) % (listSize / 2)
		}

		if (si ^ rx) < listSize {
			si ^= rx
		}

		si = ((si * p3) + r3) & listSize

		if (si ^ rx2) < listSize {
			si ^= rx2
		}

		return items.index(items.startIndex, offsetBy: Int(si))
	}

	func shuffle() -> Episodes {
		let shuffledIndicies = items.indices.map { index(index: $0) }

		return shuffledIndicies.map { items[$0] }
	}
}
