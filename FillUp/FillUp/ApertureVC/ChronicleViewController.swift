//
//  ChronicleViewController.swift
//  FillUp
//
//  Game records view controller
//

import UIKit

class ChronicleViewController: BaseViewController {
    
    var records: [VestigeRecord] = []
    
    lazy var titleLabel: UILabel = {
        let label = createLabel(fontSize: 18, weight: .bold)
        label.text = "Game Records"
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No game records yet.\nStart playing to create your first record!"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    lazy var clearAllButton: UIButton = createStyledButton(title: "Clear All Records", backgroundColor: UIColor.systemRed.withAlphaComponent(0.7))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecordsViews()
        loadRecords()
    }
    
    func setupRecordsViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(clearAllButton)
        
        clearAllButton.addTarget(self, action: #selector(clearAllButtonTapped), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChronicleTableViewCell.self, forCellReuseIdentifier: "RecordCell")
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: clearAllButton.topAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            clearAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            clearAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            clearAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            clearAllButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func loadRecords() {
        records = VestigeDataManager.shared.retrieveRecords()
        updateUI()
        tableView.reloadData()
    }
    
    func updateUI() {
        let hasRecords = !records.isEmpty
        emptyStateLabel.isHidden = hasRecords
        tableView.isHidden = !hasRecords
        clearAllButton.isHidden = !hasRecords
    }
    
    @objc func clearAllButtonTapped() {
        let alert = UIAlertController(title: "Clear All Records", message: "Are you sure you want to delete all game records? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { _ in
            VestigeDataManager.shared.obliterateAllRecords()
            self.loadRecords()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ChronicleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! ChronicleTableViewCell
        let record = records[indexPath.row]
        cell.configure(with: record, index: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            VestigeDataManager.shared.obliterateRecord(at: indexPath.row)
            loadRecords()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - ChronicleTableViewCell
class ChronicleTableViewCell: UITableViewCell {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(rankLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(detailsLabel)
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),
            
            scoreLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 15),
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            detailsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            detailsLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 15),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            dateLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
    }
    
    func configure(with record: VestigeRecord, index: Int) {
        rankLabel.text = "\(index)"
        scoreLabel.text = "Score: \(record.score)"
        
        let durationText = formatDuration(record.duration)
        let modeName = getGameModeName(record.gameMode)
        detailsLabel.text = "Rounds: \(record.roundsCompleted) | \(modeName) | Type: \(getTileTypeName(record.tileType)) | Time: \(durationText)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: record.timestamp)
    }
    
    func formatDuration(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = seconds.truncatingRemainder(dividingBy: 60)
        if minutes > 0 {
            return String(format: "%dm %.1fs", minutes, secs)
        } else {
            return String(format: "%.1fs", secs)
        }
    }
    
    func getTileTypeName(_ typeString: String) -> String {
        switch typeString {
        case "fillA": return "Bamboo"
        case "fillB": return "Character"
        case "fillC": return "Circle"
        default: return typeString
        }
    }
    
    func getGameModeName(_ modeString: String) -> String {
        switch modeString {
        case "classic": return "Basic"
        case "mixed": return "Mixed"
        default: return modeString
        }
    }
}

