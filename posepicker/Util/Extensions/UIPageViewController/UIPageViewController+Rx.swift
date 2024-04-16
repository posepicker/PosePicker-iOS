//
//  UIPageViewController+Rx.swift
//  posepicker
//
//  Created by 박경준 on 3/28/24.
//

import RxCocoa
import RxSwift
import UIKit

extension UIPageViewController: HasDelegate { }

class UIPageViewControllerDelegateProxy: DelegateProxy<UIPageViewController, UIPageViewControllerDelegate>, DelegateProxyType, UIPageViewControllerDelegate {

    init(parentObject: UIPageViewController) {
        super.init(
            parentObject: parentObject,
            delegateProxy: UIPageViewControllerDelegateProxy.self
        )
    }

    public static func registerKnownImplementations() {
        self.register { UIPageViewControllerDelegateProxy(parentObject: $0) }
    }

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        spineLocationForRelay.value[orientation] ?? .none
    }

    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        supportedInterfaceOrientations.value
    }

    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        preferredInterfaceOrientationForPresentation.value
    }

    fileprivate let supportedInterfaceOrientations =
        BehaviorRelay<UIInterfaceOrientationMask>(value: .allButUpsideDown)

    fileprivate let spineLocationForRelay = BehaviorRelay<[UIInterfaceOrientation: UIPageViewController.SpineLocation]>(value: [:])

    fileprivate let preferredInterfaceOrientationForPresentation = BehaviorRelay<UIInterfaceOrientation>(value: UIInterfaceOrientation.portraitUpsideDown)
}

extension Reactive where Base: UIPageViewController {

    var delegate: UIPageViewControllerDelegateProxy {
        return UIPageViewControllerDelegateProxy.proxy(for: base)
    }

    var willTransitionTo: Observable<[UIViewController]> {
        delegate.methodInvoked(#selector(UIPageViewControllerDelegate.pageViewController(_:willTransitionTo:)))
            .map { $0[1] as! [UIViewController] }
    }

    var didFinishAnimating: Observable<(finished: Bool, previousViewControllers: [UIViewController], completed: Bool)> {
        delegate.methodInvoked(#selector(UIPageViewControllerDelegate.pageViewController(_:didFinishAnimating:previousViewControllers:transitionCompleted:)))
            .map { ($0[1] as! Bool, $0[2] as! [UIViewController], $0[3] as! Bool) }
    }

    var spineLocationFor: Binder<[UIInterfaceOrientation: UIPageViewController.SpineLocation]> {
        Binder(delegate) { del, value in
            del.spineLocationForRelay.accept(value)
        }
    }

    var supportedInterfaceOrientations: Binder<UIInterfaceOrientationMask> {
        Binder(delegate) { del, value in
            del.supportedInterfaceOrientations.accept(value)
        }
    }

    var preferredInterfaceOrientationForPresentation: Binder<UIInterfaceOrientation> {
        Binder(delegate) { del, value in
            del.preferredInterfaceOrientationForPresentation.accept(value)
        }
    }
}
