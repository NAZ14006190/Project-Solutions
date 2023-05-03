//
//  ProjectListViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 26/04/2023.
//
/*
import Foundation
import UIKit

private let reuseIdentifier = "Cell"

class ProjectListViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Project.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int,  Project.ID>
    
    var currentUserId: Int?
    var dataSource: DataSource!
    var projects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemGray6

        if let currentUser = UserData.shared.currentUser {
            currentUserId = currentUser.id
        }

        if let userId = currentUserId {
            let url = URL(string: "http://127.0.0.1:5000/api/projects/get/by_user_id/\(userId)")!
            URLSession.shared.fetchData(for: url) { (result: Result<[Project], Error>) in
                switch result {
                case .success(let results):
                    self.projects.append(contentsOf: results)
                    print("Fetched projects: \(results)") // Add this line
                    self.updateSnapshot()
                case .failure(let error):
                    print(error)
                }
            }
        }
    
        
        let listLayout = listLayout()
        
        collectionView.collectionViewLayout = listLayout
        
        let cellRegistration = UICollectionView.CellRegistration {
            
            (cell: UICollectionViewListCell, indexPath: IndexPath, itemIdentifier: Project.ID) in
            
            let project = self.project(withId: itemIdentifier)
            
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = project.name
            contentConfiguration.secondaryText = project.isComplete ? "Complete" : "In progress"
            contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(
                forTextStyle: .caption1)
            cell.contentConfiguration = contentConfiguration
            
            var doneButtonConfiguration = self.doneButtonConfiguration(for: project)
            doneButtonConfiguration.tintColor = .systemPink
            cell.accessories = [
                .customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)
            ]
            
            
            var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfiguration.backgroundColor = .systemGray6
            cell.backgroundConfiguration = backgroundConfiguration
            
        }
        
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Project.ID) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
    }
    
    private func doneButtonConfiguration(for project: Project)
    -> UICellAccessory.CustomViewConfiguration
    {
        let symbolName = project.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ProjectDoneButton()
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = project.id
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(
            customView: button, placement: .leading(displayed: .always))
    }
    
    override func collectionView(
        _ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let id = projects[indexPath.item].id
        pushDetailViewForProject(withId: id)
        return false
    }

    func pushDetailViewForProject(withId id: Project.ID) {
        if let userId = currentUserId {
            let viewController = ViewProjectsViewController(currentUserId: userId)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    func project(withId id: Project.ID) -> Project {
        let index = projects.indexOfProject(withId: id)
        return projects[index]
    }
    
    
    func updateProject(_ project: Project) {
        let index = projects.indexOfProject(withId: project.id)
        projects[index] = project
    }
    
    func completeProject(withId id: Project.ID) {
        var project = project(withId: id)
        project.isComplete.toggle()
        updateProject(project)
        
        let urlString = "http://127.0.0.1:5000/api/projects/update/\(project.id)"
        URLSession.shared.putData(project, urlString: urlString)
        { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedProject):
                    self.updateProject(updatedProject)
                    self.updateSnapshot(reloading: [id])
                case .failure(let error):
                    print("Error updating project in API:", error)
                }
            }
        }
    }
    
    @objc func didPressDoneButton(_ sender: ProjectDoneButton) {
        guard let id = sender.id else { return }
        completeProject(withId: id)
    }
    
    func updateSnapshot(reloading ids: [Project.ID] = []) {
           var snapshot = Snapshot()
           snapshot.appendSections([0])
           snapshot.appendItems(projects.map { $0.id })
           if !ids.isEmpty {
               snapshot.reloadItems(ids)
           }
           dataSource.apply(snapshot)
       }

    
}

class ProjectDoneButton: UIButton {
    var id: Project.ID?
}

*/
