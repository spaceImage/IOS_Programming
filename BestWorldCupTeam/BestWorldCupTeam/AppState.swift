import Foundation

extension Notification.Name {
    static let dreamTeamChanged = Notification.Name("dreamTeamChanged")
}

final class AppState {
    static let shared = AppState()
    private init() { load() }

    // 슬롯 id → 선수 id
    private(set) var lineup: [String: String] = [:]
    private(set) var formation: String = "4-3-3"
    private(set) var saved: Bool = false

    private let key = "dxi_state_v1"

    // MARK: 파생 값
    var count: Int { lineup.count }
    var pickedIDs: Set<String> { Set(lineup.values) }
    var players: [Player] { lineup.values.compactMap { DataStore.player($0) } }
    var avgOVR: Int {
        let ps = players
        guard !ps.isEmpty else { return 0 }
        return Int((ps.map { $0.ovr }.reduce(0, +) / ps.count))
    }
    var slots: [Slot] { DataStore.formations[formation] ?? [] }
    func player(inSlot id: String) -> Player? {
        guard let pid = lineup[id] else { return nil }
        return DataStore.player(pid)
    }
    func isPicked(_ id: String) -> Bool { pickedIDs.contains(id) }

    // MARK: 액션
    /// 픽/해제. 결과 메시지를 반환(토스트용). nil이면 무시.
    @discardableResult
    func togglePick(_ player: Player) -> String {
        if isPicked(player.id) {
            if let slot = lineup.first(where: { $0.value == player.id })?.key { lineup[slot] = nil }
            saved = false; commit()
            return "\(player.name) 선수를 드림팀에서 뺐어요"
        }
        guard count < 11 else { return "드림팀이 이미 11명으로 가득 찼어요" }
        // 같은 포지션의 빈 슬롯 우선, 없으면 임의의 빈 슬롯
        let empty = slots.first { lineup[$0.id] == nil && $0.cat == player.cat }
            ?? slots.first { lineup[$0.id] == nil }
        guard let slot = empty else { return "드림팀이 가득 찼어요" }
        lineup[slot.id] = player.id
        saved = false; commit()
        return "⭐ \(player.name) → \(slot.label) 자리에 픽 완료!"
    }

    /// 드래그 교체: 두 슬롯의 선수를 맞바꾼다(빈 슬롯이면 이동).
    func swap(_ from: String, _ to: String) {
        let a = lineup[from], b = lineup[to]
        if let b = b { lineup[from] = b; lineup[to] = a }
        else { lineup[from] = nil; lineup[to] = a }
        saved = false; commit()
    }

    /// 포메이션 변경: 현재 선수들을 새 포메이션 슬롯에 포지션 기준으로 재배치.
    func setFormation(_ f: String) {
        let ids = Array(lineup.values)
        let newSlots = DataStore.formations[f] ?? []
        var nl: [String: String] = [:]
        for id in ids {
            guard let p = DataStore.player(id) else { continue }
            let slot = newSlots.first { nl[$0.id] == nil && $0.cat == p.cat }
                ?? newSlots.first { nl[$0.id] == nil }
            if let s = slot { nl[s.id] = id }
        }
        lineup = nl; formation = f; saved = false; commit()
    }

    func reset() { lineup = [:]; saved = false; commit() }

    func save() { saved = true; persist() ; NotificationCenter.default.post(name: .dreamTeamChanged, object: nil) }

    // MARK: 영속
    private func commit() {
        persist()
        NotificationCenter.default.post(name: .dreamTeamChanged, object: nil)
    }
    private func persist() {
        let dict: [String: Any] = ["lineup": lineup, "formation": formation, "saved": saved]
        UserDefaults.standard.set(dict, forKey: key)
    }
    private func load() {
        guard let d = UserDefaults.standard.dictionary(forKey: key) else { return }
        if let l = d["lineup"] as? [String: String] { lineup = l }
        if let f = d["formation"] as? String { formation = f }
        if let s = d["saved"] as? Bool { saved = s }
    }
}
