//
//  EmployeeDAO.swift
//  HR
//
//  Created by MC975-107 on 19/09/2019.
//  Copyright © 2019 comso. All rights reserved.
//

enum EmpStateType: Int {
    case ING = 0, STOP, OUT // 순서대로 재직중(0), 휴직(1), 퇴사(2)
    // 재직 상태를 문자열로 변환해 주는 메소드
    func desc() -> String {
        switch self {
        case .ING:
            return "재직중"
        case .STOP:
            return "휴직"
        case .OUT:
            return "퇴사"
        }
    }
}

struct EmployeeVO {
    var empCd = 0           // 사원 코드
    var empName = ""    // 사원명
    var joinDate = ""      // 입사일
    var stateCd = EmpStateType.ING // 재직 상태 (기본값 - 재직중)
    var departCd = 0     // 소속 부서 코드
    var departTitle = "" // 소속 부서명
}

class EmployeeDAO {
    lazy var fmdb: FMDatabase! = {
        let fileMgr = FileManager.default
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("hr.sqlite").path
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    func find(departCd: Int = 0) -> [EmployeeVO] {
        // 반환할 데이터를 담을 [DepartRecord] 타입의 객체 정의
        var employeeList = [EmployeeVO]()
        do {
            let condition = departCd == 0 ? "" : "WHERE Employee.depart_cd = \(departCd)"
            // 부서 정보 목록을 가져올 SQL 작성 및 쿼리 실행
            let sql = """
                SELECT emp_cd, emp_name, join_date, state_cd, department.depart_title
                FROM employee
                JOIN department On department.depart_cd = employee.depart_cd
                \(condition)
                ORDER BY department.depart_cd ASC
            """
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            // 결과 집합 추출
            while rs.next() {
                var record = EmployeeVO()
                record.empCd = Int(rs.int(forColumn: "emp_cd"))
                record.empName = rs.string(forColumn: "emp_name")!
                record.joinDate = rs.string(forColumn: "join_date")!
                record.departTitle = rs.string(forColumn: "depart_title")!
                let cd = Int(rs.int(forColumn: "state_cd")) // DB에서 읽어온 state_cd 값
                record.stateCd = EmpStateType(rawValue: cd)!
                employeeList.append(record)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        return employeeList
    }
    
    func get(empCd: Int) -> EmployeeVO? {
        let sql = """
            SELECT emp_cd, emp_name, join_date, state_cd, department.depart_title
            FROM employee
            JOIN department On department.depart_cd = employee.depart_cd
            WHERE emp_cd = ?
        """
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [empCd])
        // 결과 집합 처리
        if let _rs = rs { // 결과 집합이 옵셔널 타입으로 반환되므로, 이를 일반 상수에 바인딩하여 해제한다.
            _rs.next()
            var record = EmployeeVO()
            record.empCd = Int(_rs.int(forColumn: "emp_cd"))
            record.empName = _rs.string(forColumn: "emp_name")!
            record.joinDate = _rs.string(forColumn: "join_date")!
            record.departTitle = _rs.string(forColumn: "depart_title")!
            let cd = Int(_rs.int(forColumn: "state_cd")) // DB에서 읽어온 state_cd 값
            record.stateCd = EmpStateType(rawValue: cd)!
            return record
        } else { // 결과 집합이 없을 경우 nil을 반환한다.
            return nil
        }
    }
    
    func create(param: EmployeeVO) -> Bool {
        do {
            let sql = """
                INSERT INTO employee (emp_name, join_date, state_cd, depart_cd)
                VALUES( ? , ? , ? , ? )
            """
            // Prepared Statement 를 위한 인자값
            var params = [Any]()
            params.append(param.empName)
            params.append(param.joinDate)
            params.append(param.stateCd.rawValue)
            params.append(param.departCd)
            try self.fmdb.executeUpdate(sql, values: params)
            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func remove(empCd: Int) -> Bool {
        do {
            let sql = "DELETE FROM employee WHERE emp_cd = ?"
            try self.fmdb.executeUpdate(sql, values: [empCd])
            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func editState(empCd: Int, stateCd: EmpStateType) -> Bool {
        do {
            let sql = "UPDATE Employee SET state_cd = ? WHERE emp_cd = ? "
            
            // 인자값 배열
            var params = [Any]()
            params.append(stateCd.rawValue)
            params.append(empCd)
            
            // 업데이트 실행
            try self.fmdb.executeUpdate(sql, values: params)
            return true
        } catch let error as NSError {
            print("UPDATE Error: \(error.localizedDescription)")
            return false
        }
    }
}
