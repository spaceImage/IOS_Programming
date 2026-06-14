import UIKit

// MARK: - 포지션 분류

enum PosCat: String, Codable {
    case GK, DF, MF, FW
    var label: String { rawValue }
    var korName: String {
        switch self {
        case .GK: return "골키퍼"; case .DF: return "수비수"
        case .MF: return "미드필더"; case .FW: return "공격수"
        }
    }
    var color: UIColor {
        switch self {
        case .GK: return UIColor(hex: "#FFC247")
        case .DF: return UIColor(hex: "#48C9FF")
        case .MF: return UIColor(hex: "#00E676")
        case .FW: return UIColor(hex: "#FF5D6C")
        }
    }
}

// MARK: - 국가

struct Nation {
    let code: String
    let name: String
    let flag: String   // 이모지 국기 (실제 앱에선 에셋 이미지로 교체 가능)
    let conf: String   // 대륙
    let color: UIColor
}

// MARK: - 능력치

struct Stat { let label: String; let value: Int }

// MARK: - 선수

struct Player {
    let id: String
    let natCode: String
    let name: String
    let club: String     // 소속 클럽 (데모용 근사치)
    let pos: String      // 세부 포지션 (ST, CB ...)
    let cat: PosCat
    let number: Int
    let foot: String
    let age: Int
    let ovr: Int
    let stats: [Stat]

    var nation: Nation { DataStore.nations[natCode]! }
    var teamName: String { nation.name }
    var flag: String { nation.flag }
    var conf: String { nation.conf }

    /// OVR을 10단위로 끊은 등급 (S/A/B/C/D)
    var tier: Tier {
        switch ovr {
        case 90...: return .S
        case 80...89: return .A
        case 70...79: return .B
        case 60...69: return .C
        default: return .D
        }
    }
}

// MARK: - 선수 등급 (OVR 10단위)

enum Tier: String {
    case S, A, B, C, D
    var label: String { rawValue }
    var color: UIColor {
        switch self {
        case .S: return UIColor(hex: "#FFD600")   // 골드
        case .A: return UIColor(hex: "#C0C8D0")   // 실버
        case .B: return UIColor(hex: "#CD7F32")   // 브론즈
        case .C: return UIColor(hex: "#8A8F98")   // 그레이
        case .D: return UIColor(hex: "#5A5F68")   // 다크그레이
        }
    }
    var desc: String {
        switch self {
        case .S: return "월드클래스"
        case .A: return "정상급"
        case .B: return "준수"
        case .C: return "로테이션"
        case .D: return "유망/후보"
        }
    }
}

// MARK: - 포메이션 슬롯 (Ch05 프로그래밍 방식 좌표, 0~100%)

struct Slot {
    let id: String
    let cat: PosCat
    let label: String
    let x: CGFloat       // 0(좌)~100(우)
    let y: CGFloat       // 0(상/공격)~100(하/자기진영)
}

// MARK: - 데이터 스토어

enum DataStore {

    static let confs = ["전체", "유럽", "남미", "아시아", "북중미", "아프리카"]
    static let filters: [String] = ["전체", "FW", "MF", "DF", "GK"]

    static let nations: [String: Nation] = {
        var m = [String: Nation]()
        let rows: [(String,String,String,String,String)] = [
            ("ARG","아르헨티나","🇦🇷","남미","#75AADB"),
            ("BRA","브라질","🇧🇷","남미","#1EAE54"),
            ("URU","우루과이","🇺🇾","남미","#4AA3DF"),
            ("FRA","프랑스","🇫🇷","유럽","#3556A3"),
            ("ENG","잉글랜드","🏴󠁧󠁢󠁥󠁮󠁧󠁿","유럽","#D2283B"),
            ("POR","포르투갈","🇵🇹","유럽","#0A8E54"),
            ("ESP","스페인","🇪🇸","유럽","#D4233A"),
            ("NED","네덜란드","🇳🇱","유럽","#F07A2B"),
            ("GER","독일","🇩🇪","유럽","#C7B257"),
            ("BEL","벨기에","🇧🇪","유럽","#D8A21A"),
            ("CRO","크로아티아","🇭🇷","유럽","#D33B3B"),
            ("KOR","대한민국","🇰🇷","아시아","#2C6FD4"),
            ("JPN","일본","🇯🇵","아시아","#C8243A"),
            ("USA","미국","🇺🇸","북중미","#2C4C9C"),
            ("MEX","멕시코","🇲🇽","북중미","#1B7A45"),
            ("MAR","모로코","🇲🇦","아프리카","#B81F33"),
            ("RSA","남아프리카공화국","🇿🇦","아프리카","#1A7A4C"),
            ("CZE","체코","🇨🇿","유럽","#11457E"),
            ("CAN","캐나다","🇨🇦","북중미","#D52B1E"),
            ("BIH","보스니아","🇧🇦","유럽","#1B3C8C"),
            ("PAR","파라과이","🇵🇾","남미","#D32D27"),
            ("QAT","카타르","🇶🇦","아시아","#7D1A3A"),
            ("SUI","스위스","🇨🇭","유럽","#D52B1E"),
            ("HAI","아이티","🇭🇹","북중미","#00209F"),
            ("SCO","스코틀랜드","🏴󠁧󠁢󠁳󠁣󠁴󠁿","유럽","#0A4C8C"),
            ("AUS","호주","🇦🇺","아시아","#0C2577"),
            ("TUR","튀르키예","🇹🇷","유럽","#C8102E"),
        ]
        for r in rows { m[r.0] = Nation(code: r.0, name: r.1, flag: r.2, conf: r.3, color: UIColor(hex: r.4)) }
        return m
    }()

    // 포지션 아키타입 → ovr에 더하는 6개 능력치 보정값 [페이스,슈팅,패스,드리블,수비,피지컬]
    private static let profiles: [String:[Int]] = [
        "ST":[2,7,-9,1,-30,5], "CF":[3,6,-6,3,-28,3],
        "LW":[9,1,-2,7,-26,-7], "RW":[9,1,-2,7,-26,-7],
        "CAM":[-1,3,7,8,-18,-9], "LM":[7,-1,3,5,-12,-6], "RM":[7,-1,3,5,-12,-6],
        "CM":[-5,-3,7,3,1,2], "CDM":[-7,-9,3,-3,9,9],
        "LB":[8,-15,1,-1,7,2], "RB":[8,-15,1,-1,7,2],
        "LWB":[10,-11,3,2,3,1], "RWB":[10,-11,3,2,3,1],
        "CB":[-5,-29,-7,-13,9,9],
    ]
    private static let outLabels = ["페이스","슈팅","패스","드리블","수비","피지컬"]
    private static let gkLabels  = ["다이빙","핸들링","킥","반응","스피드","위치선정"]

    private static func hash(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h ^= UInt32(b); h = h &* 16777619 }
        return h
    }
    private static func clamp(_ v: Int) -> Int { max(42, min(99, v)) }

    private static func genStats(cat: PosCat, pos: String, ovr: Int, name: String) -> [Stat] {
        let seed = hash(name + pos)
        func jit(_ i: Int) -> Int { Int((seed >> (i*3)) & 7) - 3 }   // -3...+3
        if cat == .GK {
            let deltas = [1,-1,-5,2,-32,-2]
            return (0..<6).map { Stat(label: gkLabels[$0], value: clamp(ovr + deltas[$0] + jit($0))) }
        }
        let d = profiles[pos] ?? profiles["CM"]!
        return (0..<6).map { Stat(label: outLabels[$0], value: clamp(ovr + d[$0] + jit($0))) }
    }

    // 로스터: (이름, 클럽, 세부포지션, 분류, 등번호, 주발, 나이, OVR)  ※ 클럽은 데모용 근사치
    static let players: [Player] = {
        let R = "오른발", L = "왼발", B = "양발"
        let roster: [String:[(String,String,String,PosCat,Int,String,Int,Int)]] = [
            "ARG":[("E. 마르티네스","아스톤 빌라","GK",.GK,23,R,33,86),("루야니","라싱","GK",.GK,12,R,26,79),
                ("로메로","토트넘","CB",.DF,13,R,27,86),("오타멘디","벤피카","CB",.DF,19,R,37,82),("몰리나","아틀레티코","RB",.DF,26,R,27,82),("타글리아피코","리옹","LB",.DF,3,L,33,80),
                ("데 파울","아틀레티코","CM",.MF,7,R,31,84),("맥알리스터","리버풀","CM",.MF,20,R,27,86),("E. 페르난데스","첼시","CM",.MF,24,R,25,85),("파레데스","보카","CDM",.MF,5,R,31,82),
                ("메시","인터 마이애미","RW",.FW,10,L,38,90),("J. 알바레스","아틀레티코","ST",.FW,9,R,26,87),("가르나초","첼시","LW",.FW,18,R,21,82)],
            "BRA":[("알리송","리버풀","GK",.GK,1,R,33,89),("에데르송","맨시티","GK",.GK,23,R,32,85),
                ("마르키뉴스","PSG","CB",.DF,4,R,31,86),("E. 밀리탕","레알 마드리드","CB",.DF,3,R,28,85),("다닐루","플라멩구","RB",.DF,2,R,34,81),("C. 아우구스투","인터","LB",.DF,6,L,27,81),
                ("카세미루","맨유","CDM",.MF,5,R,34,84),("B. 기마랑이스","뉴캐슬","CM",.MF,8,R,28,85),("파케타","웨스트햄","CM",.MF,10,L,28,84),("제르송","플라멩구","CM",.MF,15,R,28,82),
                ("비니시우스","레알 마드리드","LW",.FW,7,R,25,90),("호드리구","레알 마드리드","RW",.FW,19,R,25,86),("하피냐","바르셀로나","RW",.FW,11,L,29,86)],
            "URU":[("로셋","페냐롤","GK",.GK,1,R,26,80),("무슬레라","갈라타사라이","GK",.GK,23,R,39,77),
                ("히메네스","아틀레티코","CB",.DF,2,R,30,84),("R. 아라우호","바르셀로나","CB",.DF,4,R,26,86),("올리베라","나폴리","LB",.DF,16,L,27,80),("바란디아란","페냐롤","RB",.DF,22,R,25,77),
                ("발베르데","레알 마드리드","CM",.MF,15,R,27,89),("벤탕쿠르","토트넘","CDM",.MF,6,R,28,83),("데 라 크루스","플라멩구","CAM",.MF,10,L,28,82),("우게테","맨유","CM",.MF,5,R,24,80),
                ("누녜스","리버풀","ST",.FW,19,R,26,84),("펠리스트리","파나티나이코스","RW",.FW,28,R,23,79),("카노비오","페냐롤","LW",.FW,11,R,27,77)],
            "FRA":[("메냥","밀란","GK",.GK,16,R,30,87),("사마바","스트라스부르","GK",.GK,1,R,25,82),
                ("살리바","아스널","CB",.DF,17,R,25,86),("우파메카노","바이에른","CB",.DF,4,R,27,85),("T. 에르난데스","밀란","LB",.DF,22,L,28,84),("쿤데","바르셀로나","RB",.DF,5,R,27,84),
                ("추아메니","레알 마드리드","CDM",.MF,8,R,26,85),("카마빙가","레알 마드리드","CM",.MF,25,L,23,84),("그리즈만","아틀레티코","CAM",.MF,7,L,35,86),("라비오","마르세유","CM",.MF,14,L,31,83),
                ("음바페","레알 마드리드","ST",.FW,10,R,27,91),("뎀벨레","PSG","RW",.FW,11,B,28,86),("콜로 무아니","유벤투스","ST",.FW,12,R,27,83)],
            "ENG":[("픽포드","에버턴","GK",.GK,1,L,31,84),("램스데일","사우샘프턴","GK",.GK,13,R,28,80),
                ("스톤스","맨시티","CB",.DF,5,R,31,84),("게이","크리스탈 팰리스","CB",.DF,6,L,30,82),("워커","맨시티","RB",.DF,2,R,35,83),("루크 쇼","맨유","LB",.DF,3,L,30,82),
                ("라이스","아스널","CDM",.MF,4,R,27,86),("벨링엄","레알 마드리드","CAM",.MF,10,R,22,90),("포든","맨시티","CM",.MF,8,L,25,87),("메이누","맨유","CM",.MF,26,R,20,81),
                ("케인","바이에른","ST",.FW,9,R,32,90),("사카","아스널","RW",.FW,7,L,24,86),("파머","첼시","RW",.FW,24,L,23,85)],
            "POR":[("D. 코스타","포르투","GK",.GK,22,R,26,85),("호제리우","브라가","GK",.GK,1,R,28,80),
                ("R. 디아스","맨시티","CB",.DF,3,R,28,87),("곤살루 이나시우","스포르팅","CB",.DF,5,L,25,82),("칸셀루","알 나스르","RB",.DF,2,R,31,84),("누누 멘데스","PSG","LB",.DF,19,L,23,84),
                ("비티냐","PSG","CM",.MF,8,R,26,84),("B. 페르난데스","맨유","CAM",.MF,8,R,31,87),("B. 실바","맨시티","CAM",.MF,10,L,31,86),("후벵 네베스","알 힐랄","CDM",.MF,18,R,28,82),
                ("호날두","알 나스르","ST",.FW,7,R,41,86),("R. 레앙","밀란","LW",.FW,15,R,26,85),("페드루 네투","첼시","RW",.FW,17,R,25,82)],
            "ESP":[("우나이 시몬","빌바오","GK",.GK,23,R,28,85),("라야","아스널","GK",.GK,1,R,30,83),
                ("르노르망","아틀레티코","CB",.DF,14,R,28,83),("쿠바르시","바르셀로나","CB",.DF,5,R,18,82),("카르바할","레알 마드리드","RB",.DF,2,R,34,84),("그리말도","레버쿠젠","LB",.DF,24,L,30,84),
                ("로드리","맨시티","CDM",.MF,16,R,29,89),("페드리","바르셀로나","CM",.MF,8,R,23,86),("가비","바르셀로나","CM",.MF,9,R,21,84),("파비안 루이스","PSG","CM",.MF,12,L,30,83),
                ("야말","바르셀로나","RW",.FW,19,L,18,87),("N. 윌리엄스","빌바오","LW",.FW,17,R,23,84),("모라타","밀란","ST",.FW,7,R,33,83)],
            "NED":[("플레컨","레버쿠젠","GK",.GK,1,R,32,82),("베르브뤼헌","브라이턴","GK",.GK,13,R,23,80),
                ("반 다이크","리버풀","CB",.DF,4,R,34,88),("더 리흐트","맨유","CB",.DF,3,R,26,84),("덤프리스","인터","RB",.DF,22,R,29,83),("아케","맨시티","LB",.DF,5,L,30,83),
                ("더 용","바르셀로나","CDM",.MF,21,R,28,87),("레이날더스","밀란","CM",.MF,14,R,23,83),("시몬스","RB 라이프치히","CAM",.MF,7,R,22,84),("스하우턴","PSV","CDM",.MF,6,R,28,80),
                ("데파이","코린치안스","ST",.FW,10,R,31,83),("학포","리버풀","LW",.FW,11,R,26,84),("하위선","인터","RW",.FW,23,R,22,81)],
            "GER":[("터 슈테겐","바르셀로나","GK",.GK,22,R,33,86),("바우만","호펜하임","GK",.GK,1,R,35,80),
                ("뤼디거","레알 마드리드","CB",.DF,2,R,32,85),("타","바이에른","CB",.DF,4,R,29,84),("키미히","바이에른","RB",.DF,6,R,30,86),("라움","RB 라이프치히","LB",.DF,3,L,27,82),
                ("크로스","은퇴","CM",.MF,8,R,35,87),("비르츠","리버풀","CAM",.MF,10,R,22,88),("무시알라","바이에른","CAM",.MF,42,R,23,88),("안드리히","레버쿠젠","CDM",.MF,23,R,31,81),
                ("하베르츠","아스널","ST",.FW,7,L,26,84),("자네","알 이티하드","LW",.FW,19,L,30,83),("풀크루크","도르트문트","ST",.FW,14,R,32,80)],
            "BEL":[("쿠르투아","레알 마드리드","GK",.GK,1,L,33,89),("카스텔스","알 카디시야","GK",.GK,12,R,33,80),
                ("사일러","RB 라이프치히","CB",.DF,24,R,24,82),("페르통언","안더레흐트","CB",.DF,5,L,38,80),("카스타뉴","풀럼","RB",.DF,15,R,30,79),("테아테","프랑크푸르트","LB",.DF,4,R,25,80),
                ("더 브라위너","나폴리","CAM",.MF,7,R,34,87),("오나나","아스톤 빌라","CDM",.MF,17,R,24,82),("틸레만스","아스톤 빌라","CM",.MF,8,R,28,82),("망갈라","리옹","CM",.MF,19,R,27,79),
                ("루카쿠","나폴리","ST",.FW,9,R,32,84),("도쿠","맨시티","LW",.FW,11,L,23,84),("트로사르","아스널","LW",.FW,10,R,31,82)],
            "CRO":[("리바코비치","오를레앙","GK",.GK,1,R,30,83),("이부시치","PAOK","GK",.GK,23,R,30,77),
                ("그바르디올","맨시티","CB",.DF,20,L,24,86),("술로크","RB 라이프치히","CB",.DF,6,R,24,80),("스타니시치","레버쿠젠","RB",.DF,2,R,25,80),("소사","아약스","LB",.DF,22,L,28,79),
                ("모드리치","밀란","CM",.MF,10,R,40,84),("코바치치","맨시티","CM",.MF,8,R,31,84),("브로조비치","알 나스르","CDM",.MF,11,R,33,83),("파샬리치","알 사드","CAM",.MF,15,R,31,80),
                ("크라마리치","호펜하임","CF",.FW,9,L,35,82),("부디미르","오사수나","ST",.FW,17,R,34,79),("바움","디나모 자그레브","LW",.FW,7,R,26,78)],
            "KOR":[("김승규","FC서울","GK",.GK,1,R,35,78),("조현우","울산","GK",.GK,21,R,34,79),
                ("김민재","바이에른","CB",.DF,4,R,29,87),("정승현","울산","CB",.DF,20,R,31,75),("김진수","전북","LB",.DF,3,L,33,76),("설영우","즈베즈다","RB",.DF,15,R,27,75),
                ("황인범","페예노르트","CM",.MF,6,R,29,78),("이강인","PSG","CAM",.MF,18,R,25,80),("홍현석","마인츠","CM",.MF,16,R,26,75),("박용우","알 아인","CDM",.MF,5,R,32,74),
                ("손흥민","토트넘","LW",.FW,7,B,33,87),("황희찬","울버햄튼","ST",.FW,9,R,30,79),("오현규","헹크","ST",.FW,10,R,24,74)],
            "JPN":[("스즈키","파르마","GK",.GK,12,R,25,78),("오사코","비셀 고베","GK",.GK,1,R,30,76),
                ("도미야스","아스널","CB",.DF,16,R,27,81),("이타쿠라","묀헨글라트바흐","CB",.DF,22,R,28,79),("스가와라","사우샘프턴","RB",.DF,2,R,28,77),("나카야마","두이스부르크","LB",.DF,5,L,28,75),
                ("엔도","리버풀","CDM",.MF,6,R,32,80),("가마다","크리스탈 팰리스","CAM",.MF,15,R,29,80),("다나카","리즈","CM",.MF,17,R,27,77),("도안","프라이부르크","RM",.MF,8,L,27,80),
                ("미토마","브라이턴","LW",.FW,9,R,28,83),("우에다","페예노르트","ST",.FW,19,R,27,78),("구보","레알 소시에다드","RW",.FW,20,L,24,81)],
            "USA":[("턴","노팅엄","GK",.GK,1,R,29,80),("스틸","콜로라도","GK",.GK,12,R,30,76),
                ("리치","유벤투스","CB",.DF,3,R,27,80),("로빈슨","풀럼","CB",.DF,5,L,28,79),("덱스터","PSV","RB",.DF,2,R,27,78),("스칼리","묀헨글라트바흐","LB",.DF,19,L,22,77),
                ("아담스","본머스","CDM",.MF,4,R,27,81),("맥케니","유벤투스","CM",.MF,8,R,27,81),("무사","호펜하임","CM",.MF,6,R,23,79),("루나","레알 솔트레이크","CAM",.MF,10,R,22,77),
                ("풀리식","밀란","LW",.FW,10,R,27,84),("발로건","모나코","ST",.FW,9,R,24,79),("레이나","우니온 베를린","RW",.FW,7,L,23,77)],
            "MEX":[("오초아","AVS","GK",.GK,13,R,40,78),("말라곤","아메리카","GK",.GK,1,R,28,78),
                ("몬테스","몬테레이","CB",.DF,5,R,28,78),("바스케스","아메리카","CB",.DF,3,R,27,76),("산체스","크루스 아술","RB",.DF,2,R,27,76),("가야르도","차르헤다드","LB",.DF,23,L,25,75),
                ("E. 알바레스","웨스트햄","CDM",.MF,4,R,28,82),("로드리게스","크루스 아술","CM",.MF,18,L,30,78),("로모","몬테레이","CM",.MF,6,R,30,76),("피네다","과달라하라","CAM",.MF,16,R,29,76),
                ("로사노","톨루카","RW",.FW,22,R,30,80),("히메네스","풀럼","ST",.FW,9,R,34,79),("안투나","과달라하라","LW",.FW,7,R,28,76)],
            "MAR":[("부누","알 힐랄","GK",.GK,1,R,34,84),("타그나우티","앙제","GK",.GK,12,R,35,78),
                ("아게르드","웨스트햄","CB",.DF,5,L,30,81),("사이스","알 샤바브","CB",.DF,6,L,35,79),("하키미","PSG","RB",.DF,2,R,27,85),("마즈라위","맨유","LB",.DF,3,R,28,81),
                ("아미라트","베식타스","CM",.MF,8,R,29,80),("우나히","마르세유","CM",.MF,4,R,25,79),("아마라","낭트","CDM",.MF,15,R,24,77),("우아하비","마르세유","CAM",.MF,7,L,25,79),
                ("엔네시리","페네르바체","ST",.FW,19,R,28,81),("지예흐","알 두하일","RW",.FW,7,L,33,81),("디아즈","레알 마드리드","LW",.FW,11,L,26,80)],
        ]
        var out = [Player]()
        // 딕셔너리 순서가 불안정하므로 국가 순서를 nations 정의 순서로 고정
        let order = ["ARG","BRA","URU","FRA","ENG","POR","ESP","NED","GER","BEL","CRO","KOR","JPN","USA","MEX","MAR"]
        for nat in order {
            guard let list = roster[nat] else { continue }
            for (idx, r) in list.enumerated() {
                out.append(Player(
                    id: nat.lowercased() + "_\(idx)",
                    natCode: nat, name: r.0, club: r.1, pos: r.2, cat: r.3, number: r.4,
                    foot: r.5, age: r.6, ovr: r.7,
                    stats: genStats(cat: r.3, pos: r.2, ovr: r.7, name: r.0)))
            }
        }
        return out
    }()

    static func player(_ id: String) -> Player? { players.first { $0.id == id } }

    // MARK: 포메이션 (Ch05 좌표)
    static let formations: [String: [Slot]] = {
        func S(_ id:String,_ c:PosCat,_ l:String,_ x:CGFloat,_ y:CGFloat) -> Slot { Slot(id:id,cat:c,label:l,x:x,y:y) }
        return [
            "4-3-3":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,71),S("lcb",.DF,"CB",38,75),S("rcb",.DF,"CB",62,75),S("rb",.DF,"RB",85,71),
                     S("lcm",.MF,"CM",27,50),S("ccm",.MF,"CM",50,45),S("rcm",.MF,"CM",73,50),
                     S("lw",.FW,"LW",19,21),S("st",.FW,"ST",50,15),S("rw",.FW,"RW",81,21)],
            "4-4-2":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,72),S("lcb",.DF,"CB",38,75),S("rcb",.DF,"CB",62,75),S("rb",.DF,"RB",85,72),
                     S("lm",.MF,"LM",16,47),S("lcm",.MF,"CM",40,50),S("rcm",.MF,"CM",60,50),S("rm",.MF,"RM",84,47),
                     S("lst",.FW,"ST",38,17),S("rst",.FW,"ST",62,17)],
            "4-2-3-1":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,73),S("lcb",.DF,"CB",38,76),S("rcb",.DF,"CB",62,76),S("rb",.DF,"RB",85,73),
                     S("ldm",.MF,"CDM",37,57),S("rdm",.MF,"CDM",63,57),
                     S("lam",.FW,"LM",18,34),S("cam",.MF,"CAM",50,35),S("ram",.FW,"RM",82,34),S("st",.FW,"ST",50,14)],
            "3-4-3":[S("gk",.GK,"GK",50,90),S("lcb",.DF,"CB",28,74),S("ccb",.DF,"CB",50,76),S("rcb",.DF,"CB",72,74),
                     S("lm",.MF,"LM",14,50),S("lcm",.MF,"CM",40,52),S("rcm",.MF,"CM",60,52),S("rm",.MF,"RM",86,50),
                     S("lw",.FW,"LW",21,19),S("st",.FW,"ST",50,15),S("rw",.FW,"RW",79,19)],
            "4-5-1":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,73),S("lcb",.DF,"CB",38,76),S("rcb",.DF,"CB",62,76),S("rb",.DF,"RB",85,73),
                     S("lm",.MF,"LM",13,48),S("lcm",.MF,"CM",34,52),S("ccm",.MF,"CM",50,55),S("rcm",.MF,"CM",66,52),S("rm",.MF,"RM",87,48),
                     S("st",.FW,"ST",50,17)],
            "3-5-2":[S("gk",.GK,"GK",50,90),S("lcb",.DF,"CB",28,75),S("ccb",.DF,"CB",50,77),S("rcb",.DF,"CB",72,75),
                     S("lwb",.MF,"LWB",13,52),S("lcm",.MF,"CM",37,53),S("ccm",.MF,"CAM",50,42),S("rcm",.MF,"CM",63,53),S("rwb",.MF,"RWB",87,52),
                     S("lst",.FW,"ST",38,17),S("rst",.FW,"ST",62,17)],
            "4-1-4-1":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,73),S("lcb",.DF,"CB",38,76),S("rcb",.DF,"CB",62,76),S("rb",.DF,"RB",85,73),
                     S("cdm",.MF,"CDM",50,60),
                     S("lm",.MF,"LM",16,42),S("lcm",.MF,"CM",38,44),S("rcm",.MF,"CM",62,44),S("rm",.MF,"RM",84,42),
                     S("st",.FW,"ST",50,15)],
            "5-3-2":[S("gk",.GK,"GK",50,90),S("lwb",.DF,"LWB",10,72),S("lcb",.DF,"CB",30,76),S("ccb",.DF,"CB",50,78),S("rcb",.DF,"CB",70,76),S("rwb",.DF,"RWB",90,72),
                     S("lcm",.MF,"CM",32,50),S("ccm",.MF,"CM",50,52),S("rcm",.MF,"CM",68,50),
                     S("lst",.FW,"ST",38,17),S("rst",.FW,"ST",62,17)],
            "4-3-1-2":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,73),S("lcb",.DF,"CB",38,76),S("rcb",.DF,"CB",62,76),S("rb",.DF,"RB",85,73),
                     S("lcm",.MF,"CM",30,55),S("ccm",.MF,"CDM",50,58),S("rcm",.MF,"CM",70,55),
                     S("cam",.MF,"CAM",50,35),
                     S("lst",.FW,"ST",38,15),S("rst",.FW,"ST",62,15)],
            "3-4-2-1":[S("gk",.GK,"GK",50,90),S("lcb",.DF,"CB",28,76),S("ccb",.DF,"CB",50,78),S("rcb",.DF,"CB",72,76),
                     S("lm",.MF,"LM",14,52),S("lcm",.MF,"CM",38,54),S("rcm",.MF,"CM",62,54),S("rm",.MF,"RM",86,52),
                     S("lam",.FW,"LW",34,28),S("ram",.FW,"RW",66,28),
                     S("st",.FW,"ST",50,14)],
            "4-4-1-1":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,73),S("lcb",.DF,"CB",38,76),S("rcb",.DF,"CB",62,76),S("rb",.DF,"RB",85,73),
                     S("lm",.MF,"LM",16,50),S("lcm",.MF,"CM",38,52),S("rcm",.MF,"CM",62,52),S("rm",.MF,"RM",84,50),
                     S("cf",.FW,"CF",50,28),
                     S("st",.FW,"ST",50,12)],
            "4-3-3 False9":[S("gk",.GK,"GK",50,90),S("lb",.DF,"LB",15,71),S("lcb",.DF,"CB",38,75),S("rcb",.DF,"CB",62,75),S("rb",.DF,"RB",85,71),
                     S("lcm",.MF,"CM",27,50),S("ccm",.MF,"CM",50,45),S("rcm",.MF,"CM",73,50),
                     S("lw",.FW,"LW",19,21),S("f9",.FW,"CF",50,28),S("rw",.FW,"RW",81,21)],
        ]
    }()

    static let formationOrder = ["4-3-3","4-4-2","4-2-3-1","3-4-3","4-5-1","3-5-2","4-1-4-1","5-3-2","4-3-1-2","3-4-2-1","4-4-1-1","4-3-3 False9"]
}

// MARK: - 최근 경기 결과 (정보 표시용, 능력치엔 영향 없음)

struct MatchResult {
    let homeCode: String   // Nation.code (예: "FRA")
    let awayCode: String
    let homeScore: Int
    let awayScore: Int
    let stage: String       // 예: "조별리그 1차전"

    var home: Nation? { DataStore.nations[homeCode] }
    var away: Nation? { DataStore.nations[awayCode] }
}

extension DataStore {
    static let recentMatches: [MatchResult] = [
        MatchResult(homeCode: "MEX", awayCode: "RSA", homeScore: 2, awayScore: 0, stage: "조별리그 1차전"),
        MatchResult(homeCode: "KOR", awayCode: "CZE", homeScore: 2, awayScore: 1, stage: "조별리그 1차전"),
        MatchResult(homeCode: "CAN", awayCode: "BIH", homeScore: 1, awayScore: 1, stage: "조별리그 1차전"),
        MatchResult(homeCode: "USA", awayCode: "PAR", homeScore: 4, awayScore: 1, stage: "조별리그 1차전"),
        MatchResult(homeCode: "QAT", awayCode: "SUI", homeScore: 1, awayScore: 1, stage: "조별리그 1차전"),
        MatchResult(homeCode: "BRA", awayCode: "MAR", homeScore: 1, awayScore: 1, stage: "조별리그 1차전"),
        MatchResult(homeCode: "HAI", awayCode: "SCO", homeScore: 0, awayScore: 1, stage: "조별리그 1차전"),
        MatchResult(homeCode: "AUS", awayCode: "TUR", homeScore: 2, awayScore: 0, stage: "조별리그 1차전"),
    ]
}
