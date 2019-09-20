//
//  DepartPickerVC.swift
//  HR
//
//  Created by MC975-107 on 20/09/2019.
//  Copyright © 2019 comso. All rights reserved.
//

import UIKit

class DepartPickerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let departDAO = DepartmentDAO() // DAO 객체
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]! // 피커뷰 데이터 소스
    var pickerView: UIPickerView!
    
    // 현재 피커 뷰에 선택된 부서 코드를 가져옴
    var selectedDepartCd: Int {
        let row = self.pickerView.selectedRow(inComponent: 0)
        return self.departList[row].departCd
    }
    
    override func viewDidLoad() {
        // DB에서 부서 목록을 가져와 튜플 배열 초기화
        self.departList = self.departDAO.find()
        
        // 피커 뷰 객체 초기화
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.view.addSubview(self.pickerView)
        
        // 외부에서 뷰 컨트롤러를 참조할 때를 위한 사이즈 지정
        let pWidth = self.pickerView.frame.width
        let pHeight = self.pickerView.frame.height
        self.preferredContentSize = CGSize(width: pWidth, height: pHeight)
    }
    // 피커 뷰에 표시될 컴포넌트 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 컴포넌트의 행 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.departList.count
    }
    
    // 피커 뷰의 각 행에 표시될 뷰를 결정
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleView = view as? UILabel
        if titleView == nil {
            titleView = UILabel()
            titleView?.font = UIFont.systemFont(ofSize: 14)
            titleView?.textAlignment = .center
        }
        
        titleView?.text = "\(self.departList[row].departTitle) (\(self.departList[row].departAddr))"
        
        return titleView!
    }
}
