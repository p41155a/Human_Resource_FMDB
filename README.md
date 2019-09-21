![ezgif com-video-to-gif (1)](https://user-images.githubusercontent.com/50395024/65372865-c80a8c00-dcb0-11e9-9abe-91fea32321f3.gif)

EmployeeDAO의 소스 
let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite") 에서 아래와 같은 오류가 반복되었습니다. 

Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value

몇시간동안이나 오류를 찾고 다시 해보기도 하였으나 결론이 나질 않았습니다.
결국 저는 add file 로 hr.sqlite를 추가하였고, 성공하였습니다. 
아마 경로를 잘 못 인식하고 있어 문제가 있었으나 add file을 하여 경로를 잘 찾은 것으로 예상됩니다

+ 업데이트 예정
값 추가시 입력을 안했다면 넘어가지 않고 경고창 뜨도록 하는 것과
사원 상세 목록을 추가시키는 것을 할 예정입니다
