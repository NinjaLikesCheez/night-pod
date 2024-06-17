//
//  ImagePlaceholderView.swift
//  Night Pod
//
//  Created by Thomas Hedderwick on 15/03/2024.
//

import SwiftUI

struct ImagePlaceholderView: View {
	var body: some View {
		ZStack {
			ProgressView()
				.aspectRatio(contentMode: .fit)
		}
	}
}
