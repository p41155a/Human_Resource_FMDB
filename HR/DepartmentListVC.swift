//
//  DepartmentListVC.swift
//  HR
//
//  Created by MC975-107 on 19/09/2019.
//  Copyright © 2019 comso. All rights reserved.
//

import UIKit

class DepartmentListVC: UITableViewController {
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]! //데이터 소스용 멤버 변수
    // 클로저 구문을 이용한 []객체를 생성 후, 이를 departList에 대입하고 있는 형태인건가?
    let departDAO = DepartmentDAO() // SQLite 처리를 담당할 DAO 객체
    // UI 초기화 함수
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "신규 부서 등록", message: "신규 부서를 등록해 주세요", preferredStyle: .alert)
        // 부서명 및 주소 입력용 텍스트 필드 추가(https://junghun0.github.io/2019/05/20/ios-alert/) 문법참고
        alert.addTextField() {(tf) in tf.placeholder = "부서명"}
        alert.addTextField() {(tf) in tf.placeholder = "주소"}
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            let title = alert.textFields?[0].text
            let addr = alert.textFields?[1].text
            if self.departDAO.create(title: title!, addr: addr!) {
                // 신규 부서 등록후 DB에서 목록 다시 읽고 테이블 뷰 갱신
                self.departList = self.departDAO.find()
                self.tableView.reloadData()
                // 내비게이션 타이틀도 변경된 부서 정보 반영
                let navTitle = self.navigationItem.titleView as! UILabel
                navTitle.text = "부서 목록 \n" + " 총 \(self.departList.count) 개"
            }
        })
        self.present(alert, animated: false)
    }
    
    func initUI() {
        // 내비게이션 타이틀용 레이블 속성 설정
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = UIFont.systemFont(ofSize: 14)
        navTitle.text = "부서 목록 \n" + " 총 \(self.departList.count) 개"
        // 내비게이션 바 UI
        self.navigationItem.titleView = navTitle // titleView에 대입
        self.navigationItem.leftBarButtonItem = self.editButtonItem // 편집 버튼 추가
        // 셀을 스와이프했을 때 해당 셀만 편집 모드가 되도록 설정
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewDidLoad() {
        self.departList = self.departDAO.find()
        self.initUI()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // indexPath 매개변수가 가리키는 행에 대한 데이터를 읽어온다.
        let rowData = self.departList[indexPath.row]
        // 셀 객체를 생성하고 데이터를 배치한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEPART_CELL")
        cell?.textLabel?.text = rowData.departTitle
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.detailTextLabel?.text = rowData.departAddr
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 화면 이동 시 전달할 부서 코드
        let departCd = self.departList[indexPath.row].departCd
        
        // 이동할 대상 뷰 컨트롤러의 인스턴스
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "DEPART_INFO")
        if let _infoVC = infoVC as? DepartmentInfoVC {
            _infoVC.departCd = departCd
            self.navigationController?.pushViewController(_infoVC, animated: true)
        }
    }
    
    // 목록 편집 형식을 경정하는 함수
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    // 수신자에서 지정된 행의 삽입 또는 삭제를 커미트하도록 데이터 소스에 요청합니다
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 삭제할 행의 departCd를 구한다
        let departCd = self.departList[indexPath.row].departCd
        //DB 에서, 데이터 소스에서 그리고 테이블 뷰에서 차례대로 삭제한다.
        if departDAO.remove(departCd: departCd) {
            self.departList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
