//
//  UIImageView+.swift
//  posepicker
//
//  Created by 박경준 on 2023/11/06.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

extension UIImageView {
    func setImage(with urlString: String) {
        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    //캐시가 존재하는 경우
                    self.image = image
                } else {
                    //캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlString) else { return }
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: urlString)
                    self.kf.setImage(with: resource)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

class UIImageViewWithDismissNotification: UIImageView {
    var dismissObservable = BehaviorRelay<Bool>(value: false)
    var backgroundAlphaObservable = PublishSubject<CGFloat>()
    
    @objc func startZooming(_ sender: UIPinchGestureRecognizer){
        
        if(sender.view!.transform.a > 0.6){
            let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
            
            guard let scale = scaleResult else { return }
            
            /// 2배 이상 확대 시도하는 경우 1.5배 확대로 강제 변경
            if sender.view!.transform.a >= 2 {
                UIView.animate(withDuration: 0.3) {
                    sender.view?.transform.a = 1.5
                    sender.view?.transform.d = 1.5
                }
                sender.state = .ended
                checkImageOriginIsZero(sender)
                return
            }
            sender.view?.transform = scale
            sender.scale = 1
        }
        
        if(sender.state == .ended){
            checkImageOriginIsZero(sender)
        }
        
    }
    
    @objc func startDragging(_ sender: UIPanGestureRecognizer){
        // 이동량을 더하는 형태 -> 계속 누적되어 목표값을 넘어서게됨
        // 직전의 translate값을 저장
        // 변화하는 상태값을 계속 트래킹하며 이미지뷰 origin위치를 변경해줘야함
        sender.view!.center.x += sender.translation(in: sender.view).x
        sender.view!.center.y += sender.translation(in: sender.view).y
        sender.setTranslation(.zero, in: sender.view)
        
        let bgAlphaRatio = (sender.view!.center.y - sender.view!.superview!.center.y) / 100
        backgroundAlphaObservable.onNext(bgAlphaRatio > 0 ? bgAlphaRatio : 0)
        
        if(sender.state == .ended){
            checkImageOriginIsZero(sender)
        }
    }
    
    func checkImageOriginIsZero(_ sender: UIPanGestureRecognizer){
        
        if self.dismissObservable.value {
            return
        }
        
        /// 너비 변환이 없는 상태일때
        if sender.view!.transform.a == 1 {
            /// 기본 위치에서 이미지가 아래로 이동한 경우
            /// 100포인트 이상 떨어진 경우 화면 dismiss하도록 수퍼뷰에 노티
            if sender.view!.center.y - sender.view!.superview!.center.y > 100 {
                dismissObservable.accept(true)
                return
            } else if sender.view!.center.y - sender.view!.superview!.center.y <= 100 {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.y = sender.view!.superview!.center.y
                }
            }
            
            /// 왼쪽 끝이 화면 왼쪽 끝에서 안으로 들어온 경우
            /// 오른쪽 끝이 화면 오른쪽 끝에서 안으로 들어온 경우
            if sender.view!.frame.origin.x > 0 || sender.view!.frame.maxX < sender.view!.superview!.frame.maxX {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.x = sender.view!.frame.width / 2
                }
            }
            
            /// 기본 위치에서 이미지가 위로 이동한 경우
            if sender.view!.center.y < sender.view!.superview!.center.y {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center = sender.view!.superview!.center
                }
            }
        }
        /// 너비변환이 이루어진 상태일때
        else {
            
            /// 기본 위치에서 이미지가 아래로 이동한 경우
            /// 100포인트 이상 떨어진 경우 화면 dismiss하도록 수퍼뷰에 노티
            /// 이미지가 확대됐을때는 최상단으로부터 이미지가 떨어져있어야됨
            if sender.view!.frame.minY > 0 && sender.view!.center.y - sender.view!.superview!.center.y > 100 {
                dismissObservable.accept(true)
                return
            } else if sender.view!.frame.minY > 0 && sender.view!.center.y - sender.view!.superview!.center.y <= 100 {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.y = sender.view!.superview!.center.y
                }
            }
            
            /// 확대 이미지가 위쪽 경계 넘어섰을때
            if sender.view!.frame.minY < 0 && sender.view!.frame.height < sender.view!.superview!.frame.height {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.y -= sender.view!.frame.origin.y
                }
            }
            
            /// 프레임이 왼쪽경계보다 안쪽으로 당겨질때
            if(sender.view!.frame.origin.x > 0){
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.x -= sender.view!.frame.origin.x
                }
            }

            /// 프레임이 오른쪽 경계보다 안쪽으로 당겨질때 - 이미지 wrapper UIView 너비로 체크
            if(sender.view!.frame.maxX < sender.view!.superview!.frame.width){
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.x += (sender.view!.superview!.frame.width - sender.view!.frame.maxX)
                }
            }
            
            /// 확대 이미지가 하단으로부터 안쪽으로 더 올라왔을때
            /// 확대 이미지 높이가 상하단 화면 경계를 넘어설때만 아래 조건문 실행해야됨
            /// 상하단 높이값이 작은상태에서 아래 조건문 실행시 이미지가 아래로 붙어버림
            if sender.view!.frame.height >= sender.view!.superview!.frame.height && sender.view!.frame.maxY < sender.view!.superview!.frame.maxY {
                UIView.animate(withDuration: 0.3) {
                    sender.view!.center.y += (sender.view!.superview!.frame.height - sender.view!.frame.maxY)
                }
            }
        }
        
        backgroundAlphaObservable.onNext(0)
    }
    
    func checkImageOriginIsZero(_ sender: UIPinchGestureRecognizer){
        
        /// 핀치 좁혀서 화면보다 너비값이 작아졌을때
        /// 원래 비율로 돌이키고 중심 수퍼뷰에 맞추기
        if sender.view!.frame.width < sender.view!.superview!.frame.width {
            UIView.animate(withDuration: 0.3) {
                sender.view!.transform.a = 1
                sender.view!.transform.d = 1
                sender.view!.center.y = sender.view!.superview!.center.y
                sender.view!.center.x = sender.view!.superview!.center.x
            }
        }
    }
    
    func enableZoom(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(pinchGesture)
    }
    
    func enableDrag(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(startDragging))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(panGesture)
    }
}
