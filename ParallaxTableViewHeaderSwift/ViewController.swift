//
//  ViewController.swift
//  ParallaxTableViewHeaderSwift
//
//  Created by Christopher Reitz on 24.04.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    let kCellIdentifier = "storyCellId"
    var comments = [String]()
    var headerView: ParallaxHeaderView {
        let headerView = ParallaxHeaderView(image: UIImage(named: "HeaderImage")!, forSize: CGSizeMake(view.frame.size.width, 300))
        headerView.headerTitleLabel.text = "I Love My Friends"

        return headerView
    }

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaceHolderComments()
        tableView.tableHeaderView = headerView
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let parallaxHeaderView = tableView.tableHeaderView as? ParallaxHeaderView {
            parallaxHeaderView.refreshBlurViewForNewImage()
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - UITableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {
        return comments.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) ??
                UITableViewCell(style: .Subtitle, reuseIdentifier: kCellIdentifier)
        guard let textLabel = cell.textLabel else { return cell }

        textLabel.text = comments[indexPath.row]
        textLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 18)
        textLabel.numberOfLines = 0

        return cell
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView == self.tableView else { return }
        guard let parallaxHeaderView = tableView.tableHeaderView as? ParallaxHeaderView else { return }

        // Pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews
        parallaxHeaderView.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
    }

    // MARK: - Private

    private func loadPlaceHolderComments() {
        comments = [
            "Friendship is always a sweet responsibility, never an opportunity",
            "True friendship is when you walk into their house and your WiFi connects automatically",
            "True friendship multiplies the good in life and divides its evils. Strive to have friends, for life without friends is like life on a desert island… to find one real friend in a lifetime is good fortune; to keep him is a blessing.",
            "Like Thought Catalog on Facebook",
            "The language of friendship is not words but meanings",
            "Don’t walk behind me; I may not lead. Don’t walk in front of me; I may not follow. Just walk beside me and be my friend.",
            "Friendship is like money, easier made than kept. – Samuel Butler",
            "A friend is one that knows you as you are, understands where you have been, accepts what you have become, and still, gently allows you to grow. – William Shakespeare",
            "I think if I’ve learned anything about friendship, it’s to hang in, stay connected, fight for them, and let them fight for you. Don’t walk away, don’t be distracted, don’t be too busy or tired, don’t take them for granted. Friends are part of the glue that holds life and faith together. Powerful stuff",
            "I value the friend who for me finds time on his calendar, but I cherish the friend who for me does not consult his calendar",
            "Every friendship travels at sometime through the black valley of despair. This tests every aspect of your affection. You lose the attraction and the magic. Your sense of each other darkens and your presence is sore. If you can come through this time, it can purify with your love, and falsity and need will fall away. It will bring you onto new ground where affection can grow again Friendship improves happiness, and abates misery, by doubling our joys, and dividing our grief Do not save your loving speeches For your friends till they are dead Do not write them on their tombstones, Speak them rather now instead"
        ]
        tableView.reloadData()
    }
}
