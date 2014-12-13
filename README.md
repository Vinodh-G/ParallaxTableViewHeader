ParallaxTableViewHeader
=======================

Parallax scrolling effect on UITableView header view when a tableView is scrolled

![solarized vim](http://i.imgur.com/xfYljPk.png)
![solarized vim](http://i.imgur.com/TBdyVeq.png)
![solarized vim](http://i.imgur.com/4ZgVLbf.png)

Usage
========
Create a ParallaxHeaderView using either of one API's
+ (id)parallaxHeaderViewWithImage:(UIImage *)image forSize:(CGSize)headerSize
+ (id)parallaxHeaderViewWithCGSize:(CGSize)headerSize

set the parallaxHeaderView to UITableViewHeader as shown below
![solarized vim](http://i.imgur.com/JKTqxDe.png)

override scrollViewDelegate method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView

Pass the UITableView or UIScrollView scrolling  contentOffset to ParallaxHeaderView as shown below.
![solarized vim](http://i.imgur.com/p4mbQeB.png)

"thats it"

Swift
======
    let headerView: ParallaxHeaderView = ParallaxHeaderView.parallaxHeaderViewWithImage(UIImage(named: "YourImageName"), forSize: CGSizeMake(self.tableview.frame.size.height, 300)) as ParallaxHeaderView
    self.tableview.tableHeaderView = headerView

    func  scrollViewDidScroll(scrollView: UIScrollView) {
        let header: ParallaxHeaderView = self.tableview.tableHeaderView as ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)

        self.tableview.tableHeaderView = header
    }

Credits
========
Used UIImage+ImageEffects (Extentions) of Created by Aaron Pang,
achiving Bluring effect to headerView, support from iOS 7.0 onwords

