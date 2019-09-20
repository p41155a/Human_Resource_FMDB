//
//  DepartmentInfoVC.swift
//  HR
//
//  Created by MC975-107 on 20/09/2019.
//  Copyright © 2019 comso. All rights reserved.
//

import UIKit

class DepartmentInfoVC: UITableViewController {
    // 부서 정보 저장 데이터 타입
    typealias DepartRecord = (departCd: Int, departTitle: String, departAdd: String)
    var departCd: Int! // 부서 코드
    // DAO 객체
    let departDAO = DepartmentDAO()
    let empDAO = EmployeeDAO()
    // 부서 정보와 사원 목록 변수
    var departInfo: DepartRecord!
    var empList: [EmployeeVO]!
    
    override func viewDidLoad() {
        self.departInfo = self.departDAO.get(departCd: self.departCd)
        self.empList = self.empDAO.find(departCd: self.departCd)
        self.navigationItem.title = "\(self.departInfo.departTitle)"
    }
    
}
