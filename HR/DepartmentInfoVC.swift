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
    typealias DepartRecord = (departCd: Int, departTitle: String, departAddr: String)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 부서 정보 섹션, 소속 사원 섹션을 사용할 것이기 때문에 2를 반환
    }
    
    // 섹션 헤더에 보일 화면 구성시
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 헤더에 들어갈 레이블 객체
        let textHeader = UILabel(frame: CGRect(x: 35, y: 5, width: 200, height: 30))
        textHeader.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(2.5))
        textHeader.textColor = UIColor(red: 0.03, green: 0.28, blue: 0.71, alpha: 1.0)
        
        // 헤더에 들어갈 이미지 뷰 객체
        let icon = UIImageView()
        icon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        
        // 섹션에 따라 타이틀, 이미지 설정
        if section == 0 {
            textHeader.text = "부서 정보"
            icon.image = UIImage(imageLiteralResourceName: "depart")
        } else {
            textHeader.text = "소속 사원"
            icon.image = UIImage(imageLiteralResourceName: "employee")
        }
        // 레이블과 이미지 뷰를 담을 컨테이너용 뷰 객체
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        v.backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 0.99, alpha: 1.0)
        // 뷰에 레이블과 이미지 뷰 추가
        v.addSubview(textHeader)
        v.addSubview(icon)
        
        return v
    }
    
    // 섹션별 헤더의 높이
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // 테이블 뷰의 목록 개수를 반환
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return self.empList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // 부서 정보 섹션
            let cell = tableView.dequeueReusableCell(withIdentifier: "DEPART_CELL")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "부서 코드"
                cell?.detailTextLabel?.text = "\(self.departInfo.departCd)"
            case 1:
                cell?.textLabel?.text = "부서명"
                cell?.detailTextLabel?.text = self.departInfo.departTitle
            case 2:
                cell?.textLabel?.text = "부서 주소"
                cell?.detailTextLabel?.text = self.departInfo.departAddr
            default:
                ()
            }
            return cell!
        } else { // 소속 사원 섹션
            let row = self.empList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMP_CELL")
            cell?.textLabel?.text = "\(row.empName) (입사일: \(row.joinDate))"
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 12)
            
            // 재직 상태 세그먼트 컨트롤
            let state = UISegmentedControl(items: ["재직중", "휴직", "퇴사"])
            state.frame.origin.x = self.view.frame.width - state.frame.width - 10
            state.frame.origin.y = 10
            state.selectedSegmentIndex = row.stateCd.rawValue
            state.tag = row.empCd // 액션 메서드에서 참조할 수 있도록 사원 코드 저장
            state.addTarget(self, action: #selector(self.changeState(_:)), for: .valueChanged)
            cell?.contentView.addSubview(state)
            return cell!
        }
    }
    
    @objc func changeState(_ sender: UISegmentedControl) {
        // 사원 코드
        let empCd = sender.tag
        // 재직 상태
        let stateCd = EmpStateType(rawValue: sender.selectedSegmentIndex)
        
        // 재직 상태 업데이트
        if self.empDAO.editState(empCd: empCd, stateCd: stateCd!) {
            let alert = UIAlertController(title: nil, message: "재직 상태가 변경되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: false)
        }
    }
}
