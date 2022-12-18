//
//  UIScrollViewWrapper.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {

    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController()
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
    }
}

class UIScrollViewViewController: UIViewController {

    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        return v
    }()

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)

        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)

    }

    func pinEdges(of containerView: UIView, to view: UIView) {
//        viewB.addConstraints([
//            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
//            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
//            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
//            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
//        ])
        
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }

}
