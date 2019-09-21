//
//  EmployeeListVC.swift
//  HR
//
//  Created by MC975-107 on 20/09/2019.
//  Copyright © 2019 comso. All rights reserved.
//

import UIKit

class EmployeeListVC: UITableViewController {
    // 데이터 소스 저장할 변수
    var empList: [EmployeeVO]!
    // SQLite DAO 클래스
    var empDAO = EmployeeDAO()
    // 새로고침 컨트롤에 들어갈 이미지 뷰
    var loadingImg: UIImageView!
    // 임계점에 도달했을 때 나타날 배경 뷰, 노란 원 형태
    var bgCircle: UIView!
    
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "사원 등록", message: "등록할 사원 정보를 입력해 주세요", preferredStyle: .alert)
        alert.addTextField() { (tf) in tf.placeholder = "사원명" }
        
        // contentViewController 영역에 피커 뷰 삽입
        let pickervc = DepartPickerVC()
        alert.setValue(pickervc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            // 알림창의 입력 필드에서 값을 읽어옴
            var param = EmployeeVO()
            param.departCd = pickervc.selectedDepartCd
            param.empName = (alert.textFields?[0].text)!
            // 가입일은 오늘로
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            param.joinDate = df.string(from: Date())
            // 재직 상태 - 재직중으로 설정
            param.stateCd = EmpStateType.ING
            // DB 처리
            if self.empDAO.create(param: param) {
                // create가 성공하면 데이터를 다시 읽어와 테이블 뷰를 갱신
                self.empList = self.empDAO.find()
                self.tableView.reloadData()
                
                // 내비게이션 타이틀 갱신
                if let navTitle = self.navigationItem.titleView as? UILabel {
                    navTitle.text = "사원 목록 \n" + " 총 \(self.empList.count) 명"
                }
            }
        })
        
        self.present(alert, animated: false)
    }
    
    @IBAction func editing(_ sender: Any) {
        if self.isEditing == false { // 편집 모드가 아닐 때
            self.setEditing(true, animated: true)
            (sender as? UIBarButtonItem)?.title = "Done"
            (sender as? UIBarButtonItem)?.style = .done
        } else { // 편집 모드 일 때
            self.setEditing(false, animated: true)
            (sender as? UIBarButtonItem)?.title = "Edit"
            (sender as? UIBarButtonItem)?.style = .plain
        }
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        // 새로고침 시 갱신 되어야할 내용
        self.empList = self.empDAO.find()
        self.tableView.reloadData()
        // 당겨서 새로고침 종료
        self.refreshControl?.endRefreshing()
        // 노란 원이 로딩 이미지를 중심으로 커지는 애니메이션
        let distance = max(0.0, -(self.refreshControl?.frame.origin.y)!)
        UIView.animate(withDuration: 0.5) {
            self.bgCircle.frame.size.width = 80
            self.bgCircle.frame.size.height = 80
            self.bgCircle.center.x = (self.refreshControl?.frame.width)! / 2
            self.bgCircle.center.y = distance / 2
            self.bgCircle.layer.cornerRadius = (self.bgCircle?.frame.size.width)! / 2
        }
    }
    
    func initUI() {
        // 내비게이션 타이틀용 레이블 속성 설정
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = UIFont.systemFont(ofSize: 14)
        navTitle.text = "사원 목록 \n" + " 총 \(self.empList.count) 명"
        
        self.navigationItem.titleView = navTitle
    }
    
    override func viewDidLoad() {
        self.empList = self.empDAO.find()
        self.initUI()
        
        // 당겨서 새로고침
        self.refreshControl = UIRefreshControl()
        // 새로고침 커스텀을 위한 주석처리
        //self.refreshControl?.attributedTitle = NSAttributedString(string : "당겨서 새로고침")
        self.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        // 로딩 이미지 초기화
        self.loadingImg = UIImageView(image: UIImage(named: "refresh"))
        self.loadingImg.center.x = (self.refreshControl?.frame.width)! / 2
        self.refreshControl?.tintColor = .clear
        self.refreshControl?.addSubview(self.loadingImg)
        // 배경 뷰 초기화
        self.bgCircle = UIView()
        self.bgCircle.backgroundColor = .yellow
        self.bgCircle.center.x = (self.refreshControl?.frame.width)! / 2
        // 배경 뷰를 refreshControl 객체에 추가하고 로딩 이미지를 위로 올림
        self.refreshControl?.addSubview(self.bgCircle)
        self.refreshControl?.bringSubviewToFront(self.loadingImg)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.empList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = self.empList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMP_CELL")
        // 사원명, 재직 상태 출력
        cell?.textLabel?.text = rowData.empName + "(\(rowData.stateCd.desc()))"
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.detailTextLabel?.text = rowData.departTitle
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        
        return cell!
    }
    
    // 편집 형식을 결정하는 메서드
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 삭제할 행의 empCd를 구함
        let empCd = self.empList[indexPath.row].empCd
        
        // DB, 데이터 소스, 테이블 뷰에서 삭제
        if empDAO.remove(empCd: empCd) {
            self.empList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.empList = self.empDAO.find()
            self.tableView.reloadData()
            // 내비게이션 타이틀 갱신
            if let navTitle = self.navigationItem.titleView as? UILabel {
                navTitle.text = "사원 목록 \n" + " 총 \(self.empList.count) 명"
            }
        }
    }
    
    // 스크롤이 발생할 때마다 처리할 내용을 여기에 작성합니다
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distance = max(0.0, -(self.refreshControl?.frame.origin.y)!)
        self.loadingImg.center.y = distance / 2
        let ts = CGAffineTransform(rotationAngle: CGFloat(distance / 20))
        self.loadingImg.transform = ts
        // 배경 뷰의 중심 좌표 설정
        self.bgCircle.center.y = distance / 2
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 노란원을 초기화
        self.bgCircle.frame.size.width = 0
        self.bgCircle.frame.size.height = 0
    }
}
