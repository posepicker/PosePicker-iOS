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

extension UIImageView{
//    @objc func startZooming(_ sender: UIPinchGestureRecognizer){
//        
//        if(sender.view!.transform.a > 0.6){
//            let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
//            
//            guard let scale = scaleResult else { return }
//            sender.view?.transform = scale
//            sender.scale = 1
//        }
//        
//        if(sender.state == .ended){
////            checkImageOriginIsZero(sender)
//        }
//        
//    }
//    
//    @objc func startDragging(_ sender: UIPanGestureRecognizer){
//        // 이동량을 더하는 형태 -> 계속 누적되어 목표값을 넘어서게됨
//        // 직전의 translate값을 저장
//        // 변화하는 상태값을 계속 트래킹하며 이미지뷰 origin위치를 변경해줘야함
//        print(sender.location(in: sender.view))
//        sender.view!.center.x += sender.translation(in: sender.view).x
//        sender.view!.center.y += sender.translation(in: sender.view).y
//        sender.setTranslation(.zero, in: sender.view)
//        
//        if(sender.state == .ended){
//            checkImageOriginIsZero(sender)
//        }
//    }
    
    /// 팬제스처 종료 이후 제자리로 돌아갈지 여부를 판단하여 동작하는 함수
    /// 너비 확대 및 축소가 이루어진 경우 origin.x값은 제자리를 벗어날 수 밖에 없게됨
    /// 너비 확대가 이루어지지 않은 경우부터 체크
//    func checkImageOriginIsZero(_ sender: UIPanGestureRecognizer){
//        
//        /// 너비 변환이 이루어졌을때
//        if sender.view!.transform.a == 1 {
//            
//            /// 왼쪽 끝이 화면 왼쪽 끝에서 안으로 들어온 경우
//            /// 오른쪽 끝이 화면 오른쪽 끝에서 안으로 들어온 경우
//            if sender.view!.frame.origin.x > 0 || sender.view!.frame.maxX < sender.view!.superview!.frame.maxX {
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x = sender.view!.frame.width / 2
//                }
//            }
//            
//            /// 기본 위치에서 상하로 위치 이동한 경우
//            /// 아래 특정기준 포인트로 넘어갈수록 뒷배경 하얗게 만들고 & dismiss 처리 해야됨
//            if sender.view!.center.y != sender.view!.superview!.center.y {
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center = sender.view!.superview!.center
//                }
//            }
//        }
        
//        if(sender.view!.transform.a != 1){
//            // 프레임이 왼쪽경계보다 안쪽으로 당겨질때
//            if(sender.view!.frame.origin.x > 0){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x -= sender.view!.frame.origin.x
//                }
//            }
//            
//            // 프레임이 위쪽경계보다 안쪽으로 당겨질때
//            if(sender.view!.frame.origin.y > 0  ){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y -= sender.view!.frame.origin.y
//                }
//            }
//            
//            // 프레임이 오른쪽 경계보다 안쪽으로 당겨질때 - 이미지 wrapper UIView 너비로 체크
//            if(sender.view!.frame.maxX < sender.view!.superview!.frame.width){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x += (sender.view!.superview!.frame.width - sender.view!.frame.maxX)
//                }
//            }
//            
//            // 프레임이 아래쪽 경계보다 안쪽으로 당겨질때 - 이미지 wrapper UIView 높이로 체크
//            if(sender.view!.frame.maxY < sender.view!.frame.width){
//                
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y += (sender.view!.superview!.frame.height - sender.view!.frame.maxY)
//                }
//            }
//            
//        }
//        // 아핀변환 없이 스케일링이 잘 맞춰졌을때
//        else{
//            if(sender.view!.frame.origin.x < 0){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x = sender.view!.frame.width / 2
//                }
//            }
//            
//            if(sender.view!.frame.maxX > sender.view!.frame.width){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x = sender.view!.frame.width / 2
//                }
//            }
//            
//            if(sender.view!.frame.maxY < sender.view!.frame.width){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y += sender.view!.frame.width - sender.view!.frame.maxY
//                }
//            }
//            
//            if(sender.view!.frame.minY > 0){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y -=  sender.view!.frame.minY
//                }
//            }
//        }
        // 스케일링 되어있는 경우와 그렇지 않은 경우를 구분해서 구현해야함

//    }
    
//    func checkImageOriginIsZero(_ sender: UIPinchGestureRecognizer){
//        if(sender.view!.frame.origin.x > 0 || sender.view!.frame.origin.y > 0 || sender.view!.frame.origin.x < 0 || sender.view!.frame.maxY < sender.view!.frame.width){
//            
//            let imageView = sender.view as! UIImageView
//            
//            UIView.animate(withDuration: 0.3) {
//                // PinchGesture 종료 후 너비가 높이보다 큰 경우 ratio계산 후 그 이하로는 이미지 스케일링 더 진행되지 않도록 고정
//                // CustomPickerViewController 컬렉션뷰 didSelect 프로토콜 메서드에서 이미지뷰 아핀변환값 지정하는 부분 체크
//                if(imageView.frame.height < imageView.frame.width){
//                    let ratio = imageView.frame.width / imageView.frame.height
//                    
//                    imageView.transform.a = ratio
//                    imageView.transform.d = ratio
//                }else{
//                    imageView.transform.a = 1
//                    imageView.transform.d = 1
//                }
//                
//                sender.view!.center.x = sender.view!.superview!.frame.width / 2
//                sender.view!.center.y = sender.view!.superview!.frame.height / 2
//            }
//        }
//    }
    
//    func enableZoom(){
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming))
//        self.isUserInteractionEnabled = true
//        self.addGestureRecognizer(pinchGesture)
//    }
//    
//    func enableDrag(){
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(startDragging))
//        self.isUserInteractionEnabled = true
//        self.addGestureRecognizer(panGesture)
//    }
}

class UIImageViewWithDismissNotification: UIImageView {
    var dismissObservable = BehaviorRelay<Bool>(value: false)
    
    @objc func startZooming(_ sender: UIPinchGestureRecognizer){
        
        if(sender.view!.transform.a > 0.6){
            let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
            
            guard let scale = scaleResult else { return }
            sender.view?.transform = scale
            sender.scale = 1
        }
        
        if(sender.state == .ended){
//            checkImageOriginIsZero(sender)
        }
        
    }
    
    @objc func startDragging(_ sender: UIPanGestureRecognizer){
        // 이동량을 더하는 형태 -> 계속 누적되어 목표값을 넘어서게됨
        // 직전의 translate값을 저장
        // 변화하는 상태값을 계속 트래킹하며 이미지뷰 origin위치를 변경해줘야함
        sender.view!.center.x += sender.translation(in: sender.view).x
        sender.view!.center.y += sender.translation(in: sender.view).y
        sender.setTranslation(.zero, in: sender.view)
        
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
        
//        if(sender.view!.transform.a != 1){
//            // 프레임이 왼쪽경계보다 안쪽으로 당겨질때
//            if(sender.view!.frame.origin.x > 0){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x -= sender.view!.frame.origin.x
//                }
//            }
//
//            // 프레임이 위쪽경계보다 안쪽으로 당겨질때
//            if(sender.view!.frame.origin.y > 0  ){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y -= sender.view!.frame.origin.y
//                }
//            }
//
//            // 프레임이 오른쪽 경계보다 안쪽으로 당겨질때 - 이미지 wrapper UIView 너비로 체크
//            if(sender.view!.frame.maxX < sender.view!.superview!.frame.width){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x += (sender.view!.superview!.frame.width - sender.view!.frame.maxX)
//                }
//            }
//
//            // 프레임이 아래쪽 경계보다 안쪽으로 당겨질때 - 이미지 wrapper UIView 높이로 체크
//            if(sender.view!.frame.maxY < sender.view!.frame.width){
//
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y += (sender.view!.superview!.frame.height - sender.view!.frame.maxY)
//                }
//            }
//
//        }
//        // 아핀변환 없이 스케일링이 잘 맞춰졌을때
//        else{
//            if(sender.view!.frame.origin.x < 0){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x = sender.view!.frame.width / 2
//                }
//            }
//
//            if(sender.view!.frame.maxX > sender.view!.frame.width){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.x = sender.view!.frame.width / 2
//                }
//            }
//
//            if(sender.view!.frame.maxY < sender.view!.frame.width){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y += sender.view!.frame.width - sender.view!.frame.maxY
//                }
//            }
//
//            if(sender.view!.frame.minY > 0){
//                UIView.animate(withDuration: 0.3) {
//                    sender.view!.center.y -=  sender.view!.frame.minY
//                }
//            }
//        }
        // 스케일링 되어있는 경우와 그렇지 않은 경우를 구분해서 구현해야함

    }
    
    func checkImageOriginIsZero(_ sender: UIPinchGestureRecognizer){
        if(sender.view!.frame.origin.x > 0 || sender.view!.frame.origin.y > 0 || sender.view!.frame.origin.x < 0 || sender.view!.frame.maxY < sender.view!.frame.width){
            
            let imageView = sender.view as! UIImageView
            
            UIView.animate(withDuration: 0.3) {
                // PinchGesture 종료 후 너비가 높이보다 큰 경우 ratio계산 후 그 이하로는 이미지 스케일링 더 진행되지 않도록 고정
                // CustomPickerViewController 컬렉션뷰 didSelect 프로토콜 메서드에서 이미지뷰 아핀변환값 지정하는 부분 체크
                if(imageView.frame.height < imageView.frame.width){
                    let ratio = imageView.frame.width / imageView.frame.height
                    
                    imageView.transform.a = ratio
                    imageView.transform.d = ratio
                }else{
                    imageView.transform.a = 1
                    imageView.transform.d = 1
                }
                
                sender.view!.center.x = sender.view!.superview!.frame.width / 2
                sender.view!.center.y = sender.view!.superview!.frame.height / 2
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
