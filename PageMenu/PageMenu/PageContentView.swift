//
//  PageContentView.swift
//  PageMenu
//
//  Created by zhongbin on 17/1/27.
//  Copyright © 2017年 personal. All rights reserved.
//

import UIKit

private let cellID = "cellID"

protocol PageContentViewDelegate : class {
    
    func pageContentView(pageContenView: PageContentView, progress: CGFloat, beforeIdnex: Int, targetIndex: Int)
}

class PageContentView: UIView {
    
    fileprivate var childVcs: [UIViewController]
    fileprivate weak var parentVc : UIViewController?
    fileprivate var startOffsetX : CGFloat = 0
    
    weak var delegate: PageContentViewDelegate?
    
    //初始化 collectionView
    fileprivate lazy var collectionView: UICollectionView = {[weak self] in
        
        let layout =  UICollectionViewFlowLayout()
        layout.itemSize = (self?.bounds.size)!
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let coll = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        coll.showsHorizontalScrollIndicator = false
        coll.isPagingEnabled = true
        coll.bounces = false
        coll.dataSource = self as UICollectionViewDataSource?;
        coll.delegate = self as UICollectionViewDelegate?
        coll.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        return coll
    }()
    
    //初始化方法
    init(frame: CGRect, childVcs:[UIViewController], parentVc: UIViewController?) {
        
        self.childVcs = childVcs
        self.parentVc = parentVc
        
        super.init(frame: frame)
        setUpUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func setUpUI (){
        
        for childVc in childVcs {
            parentVc?.addChildViewController(childVc)
        }
        
        addSubview(collectionView)
        collectionView.frame = bounds
    }

}

extension PageContentView : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        let childVc = childVcs[(indexPath as NSIndexPath).item]
        childVc.view.frame = self.bounds
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }

}

// MARK:- 遵守UICollectionoViewDelegate协议
extension PageContentView:UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        startOffsetX = scrollView.contentOffset.x;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 1.定义需要获取到的数据
        var progress : CGFloat = 0;
        var beforeTitleIndex : Int = 0;
        var targetTitleIndex : Int = 0;
        
        // 2.判断是左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x; // 当前的偏移量
        let scrollViewW = scrollView.bounds.width;
        if startOffsetX < currentOffsetX { // 左滑
           
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
            
            beforeTitleIndex = Int(currentOffsetX / scrollViewW);
           
            targetTitleIndex = beforeTitleIndex + 1;
            // 这里要做一下判断，防止滚到最后的时候越界
            if targetTitleIndex >= childVcs.count {
                targetTitleIndex = childVcs.count - 1;
            }
            
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1.0;
                targetTitleIndex = beforeTitleIndex;
            }
            
        } else { // 向右滑
            
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
            
            targetTitleIndex = Int(currentOffsetX / scrollViewW);
            
            beforeTitleIndex = targetTitleIndex + 1;
            if beforeTitleIndex >= childVcs.count {
                beforeTitleIndex = childVcs.count - 1;
            }
            
        }
        
        delegate?.pageContentView(pageContenView: self, progress: progress, beforeIdnex: beforeTitleIndex, targetIndex: targetTitleIndex)
    }
}


//对外暴露的方法
extension PageContentView {

    func setCurrentIndex(currentIndex: Int)  {
        
        let offsetX = (CGFloat)(currentIndex) * collectionView.frame.size.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
    }


}





