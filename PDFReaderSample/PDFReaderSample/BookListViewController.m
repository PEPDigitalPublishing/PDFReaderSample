//
//  BookListViewController.m
//  PDFReaderSample
//
//  Created by 李沛倬 on 2018/5/21.
//  Copyright © 2018年 pep. All rights reserved.
//

#import "BookListViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DeviceListViewController.h"

// MARK: - BookCollectionCell

@interface BookCollectionCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *statusLabel;

@property (nonatomic, strong) UIVisualEffectView *coverView;

@property (nonatomic, strong) PRBookModel *book;

@property (nonatomic, assign) CGFloat downloadProgress;

@end


@implementation BookCollectionCell

// MARK: - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        [self configCell];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configCell];
}


// MARK: - Setter & Getter

- (void)setBook:(PRBookModel *)book {
    _book = book;
    
    self.statusLabel.attributedText = [self getStatusAttrString];
    self.coverView.hidden = !book.isDownloading;

}

- (void)setDownloadProgress:(CGFloat)downloadProgress {
    CGFloat safetyZone = MIN(1, MAX(0, downloadProgress));
    _downloadProgress = safetyZone;
    
    self.coverView.hidden = safetyZone == 1;
    UIVisualEffectView *coverView = self.coverView;
    
    CGFloat height = coverView.superview.bounds.size.height;
    [coverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(safetyZone * height));
    }];
    
    [self.contentView setNeedsLayout];
    [UIView animateWithDuration:0.1 animations:^{
        [self.contentView layoutIfNeeded];
    }];
}

- (NSAttributedString *)getStatusAttrString {
    NSMutableAttributedString *mAttrStr = [[NSMutableAttributedString alloc] initWithString:@"购买：@  下载：@" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightLight]}];
    
    NSAttributedString *passStr = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSForegroundColorAttributeName: UIColor.greenColor}];
    NSAttributedString *notPassStr = [[NSAttributedString alloc] initWithString:@"○" attributes:@{NSForegroundColorAttributeName: UIColor.redColor}];

    [mAttrStr replaceCharactersInRange:NSMakeRange(3, 1) withAttributedString:self.book.isPurchase ? passStr : notPassStr];
    [mAttrStr replaceCharactersInRange:NSMakeRange(9, 1) withAttributedString:self.book.isDownloaded ? passStr : notPassStr];
    
    return mAttrStr;
}


// MARK: - UI

- (void)configCell {
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowOpacity = 0.4;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = false;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = true;
        
        [self.contentView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(imageView.superview);
            make.height.equalTo(imageView.mas_width).multipliedBy(4/3.0);
        }];
        
        _imageView = imageView;
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.numberOfLines = 2;
        titleLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        [self.contentView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(titleLabel.superview);
            make.bottom.equalTo(self.imageView.mas_bottom);
            make.height.equalTo(@(36));
        }];
        
        _titleLabel = titleLabel;
    }
    
    return _titleLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.numberOfLines = 1;
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
        
        [self.contentView addSubview:statusLabel];
        
        [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(statusLabel.superview);
            make.height.equalTo(@20);
        }];
        
        _statusLabel = statusLabel;
    }
    
    return _statusLabel;
}

- (UIVisualEffectView *)coverView {
    if (!_coverView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *coverView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        coverView.hidden = true;
        
        [self.contentView addSubview:coverView];
        
        [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(coverView.superview);
            make.top.equalTo(coverView.superview);
        }];
        
        _coverView = coverView;
    }
    
    return _coverView;
}



@end





// MARK: - BookListViewController

@interface BookListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerPreviewingDelegate, PRViewControllerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UICollectionView *bookCollectionView;

@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSArray<PRBookModel *> *booklist;

@property (nonatomic, assign) BOOL editing;

@property (nonatomic, weak) PRStandardViewController *readerVC;

@end

@implementation BookListViewController

// MARK: - Life Cycle

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getBooklist];
    [self resizeCollectionItemLayout];
}


// MARK: - Action

- (void)getBooklist {
    NSArray<PRBookGradeModel *> *booklist = [PRSDKManager getBooklist];
    NSMutableArray *mAry = [NSMutableArray array];
    
    for (PRBookGradeModel *grade in booklist) {    // 扁平化数据结构
        for (PRBookTermModel *term in grade.grade) {
            for (PRBookModel *book in term.textbooks) {
                if (book == nil) { continue; }
                
                [mAry addObject:book];
            }
        }
    }
    
    self.booklist = mAry;
    [self.bookCollectionView reloadData];
    
}

- (IBAction)editBarButtonItem:(UIBarButtonItem *)sender {
    self.editing = !self.editing;
    
    sender.tintColor = self.editing ? UIColor.redColor : UIColor.darkGrayColor;
    
    NSLog(self.editing ? @"进入编辑模式，可以点击删除已下载教材" : @"退出编辑模式");
}


- (IBAction)refreshBarButtonItem:(UIBarButtonItem *)sender {
    [self.indicatorView startAnimating];
    
    [PRSDKManager userAuthWithUserID:kSampleUserID successBlock:^(id response) {
        [self.indicatorView stopAnimating];
        
        if ([response isKindOfClass:NSDictionary.class] && [response[@"errcode"] intValue] == 110) {
            NSArray<Device *> *devices = [NSArray yy_modelArrayWithClass:Device.class json:response[@"devlist"]];
            
            if (devices.count >= 6) {
                [self pushIntoDeviceListViewControllerWithDeviceList:devices];
            }
            
            [self.bookCollectionView reloadData];
        } else {
            NSLog(@"%@", response);
        }
        
    } failBlock:^(NSError *error) {
        [self.indicatorView stopAnimating];

        NSLog(@"%@", error);
    }];
}

- (void)pushIntoDeviceListViewControllerWithDeviceList:(NSArray<Device *> *)deviceList {
    
    DeviceListViewController *deviceListVC = (DeviceListViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle] instantiateViewControllerWithIdentifier:@"DeviceListVC"];
    deviceListVC.datasource = deviceList.mutableCopy;
    
    [self.navigationController pushViewController:deviceListVC animated:true];
}


- (void)openBookWithModel:(PRBookModel *)bookModel {
    PRStandardViewController *vc = [[PRStandardViewController alloc] initWithBookID:bookModel.book_id pageIndex:0 purchase:true];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cellForDownloadProgressAtIndexPath:(NSIndexPath *)indexPath downloadProgress:(NSProgress *)progress {
    BookCollectionCell *cell = (BookCollectionCell *)[self.bookCollectionView cellForItemAtIndexPath:indexPath];

    cell.downloadProgress = (CGFloat)progress.completedUnitCount / progress.totalUnitCount;
}



// MARK: - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.booklist.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bookCell" forIndexPath:indexPath];
    
    PRBookModel *book = self.booklist[indexPath.row];
    if (!book) { return cell; }
    
    cell.imageView.image = nil;
    [cell.imageView setImageWithURL:[NSURL URLWithString:book.icon_url]];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@%@", book.book_name, book.grade, book.term];
    cell.book = book;
    
//    if (book.isDownloaded && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
//        [self registerForPreviewingWithDelegate:self sourceView:cell];
//    }
    
    return cell;
}


// MARK: - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
    PRBookModel *book = self.booklist[indexPath.row];
    
    if (book.isDownloading) {
        NSLog(@"下载中。。。");
        
        [PRBookDownloader pauseDownloadOfBookID:book.book_id];
        
        NSLog(@"下载已暂停！");
        return;
    }
    
    if (self.editing) { // 处于编辑模式
        
        if (book.isDownloaded) {
            [self showAlertWithTitle:@"确定要删除该教材吗？" Message:book.fullName sureButtonTitle:@"确定" cancelButtonTitle:@"取消" sureHandle:^{
                
                [[PEPFileManager shareManager] deleteDownlodedBookWithBookID:book.book_id];        // 删除已下载教材
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                
            } cancelHandle:^{
                
            }];
        } else {
            
            NSLog(@"%@-%@并未下载", book.book_id, book.fullName);
        }
        
        return;
    }
    
    [self showOpenBookOptionAlertWithBookModel:book];
    
}


// MARK: - PRViewControllerDelegate

/**
 体验模式结束，用户点击了“立即购买”按钮后将回调该代理方法
 
 @param bookModel 书本模型
 */
- (void)needPayWithBookModel:(PRBookModel *)bookModel {
    
    [self.readerVC cleanupAndCloseForReaderWithAnimated:true];  // 关闭阅读器（非必须）
    
    // TODO: - 跳转到购买教材页面

}

/**
 播放类型已经改变时将会回调该代理方法
 
 @param playingType 播放类型，详见 PRPlayingType 枚举
 */
- (void)playingTypeDidChanged:(PRPlayingType)playingType {
    
    
}


/**
 当前音频已经播放结束：每个可点击区域是一个单独的音频
 */
- (void)currentAudioPlayingDidFinished {
    
    
}

/**
 阅读器将要关闭时回调该代理方法：用户点击了工具栏上的返回按钮
 */
- (void)readerWillClose:(PRViewController *)readerVC {
    
    
}

/**
 阅读器已经关闭后将回调该代理方法：dealloc
 */
- (void)readerDidClosed {
    // TODO: - 可在此处处理本次打开教材后产生的阅读信息
    
    PRWordInfoManager *wordInfoManager = [PRWordInfoManager shareManager];
    NSString *msg = [NSString stringWithFormat:@"页码：%ld\n章节名：%@\n标题：%@", wordInfoManager.pageNumber, wordInfoManager.unit, wordInfoManager.title];
    
    NSLog(@"本次阅读进度：%@", msg);
}



// MARK: - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:PRStandardViewController.class]) { return nil; }
    
    if ([previewingContext.sourceView isKindOfClass:BookCollectionCell.class] ) {
        BookCollectionCell *cell = (BookCollectionCell *)previewingContext.sourceView;
        
        if (cell.book.isDownloaded == false) {
            [self unregisterForPreviewingWithContext:previewingContext];
            return nil;
        }
        
        NSIndexPath *indexPath = [self.bookCollectionView indexPathForCell:cell];
        
        [self.bookCollectionView deselectItemAtIndexPath:indexPath animated:true];
        
        PRStandardViewController *readerVC = [[PRStandardViewController alloc] initWithBookID:cell.book.book_id pageIndex:0 purchase:cell.book.isPurchase];
        readerVC.delegate = self;
        self.readerVC = readerVC;
        
        return readerVC;
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}




// MARK: - UI

- (void)resizeCollectionItemLayout {
    const NSInteger screenWidth = (NSInteger)[UIScreen mainScreen].bounds.size.width;
    
    if (![self.bookCollectionView.collectionViewLayout isKindOfClass:UICollectionViewFlowLayout.class]) { return; }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.bookCollectionView.collectionViewLayout;
    NSInteger itemWidth = (NSInteger)flowLayout.itemSize.width;
    
    NSInteger remainder = screenWidth % itemWidth;
    NSInteger count = screenWidth / itemWidth;
    if (remainder < 30) {
        count--;
        remainder += itemWidth;
    }
    
    CGFloat margin = (CGFloat)remainder / (count+1);
    
    self.bookCollectionView.contentInset = UIEdgeInsetsMake(20, margin, 20, margin);
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.color = UIColor.darkGrayColor;
        
        [self.view addSubview:indicatorView];
        
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(indicatorView.superview);
            make.width.height.equalTo(@60);
        }];
        
        _indicatorView = indicatorView;
    }
    
    return _indicatorView;
}



// MARK: - Private Method

- (void)downloadBookWithBookModel:(PRBookModel *)book {
    NSUInteger index = [self.booklist indexOfObject:book];
    
    if (index == NSNotFound) {
        NSLog(@"未找到该教材，下载失败！");
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    __weak typeof(self) weakSelf = self;
    
    [PRBookDownloader downloadBookWithBookID:book.book_id progress:^(NSProgress *downloadProgress) {
        [weakSelf cellForDownloadProgressAtIndexPath:indexPath downloadProgress:downloadProgress];
    } success:^(NSURL *filePath) {
        NSLog(@"%@-%@ 下载成功：%@", book.book_id, book.fullName, filePath.absoluteString);
        
        [weakSelf.bookCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    } fail:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}


- (void)openBookWithBookModel:(PRBookModel *)book {
    PRStandardViewController *readerVC = [[PRStandardViewController alloc] initWithBookID:book.book_id pageIndex:0 purchase:book.purchase];
    readerVC.delegate = self;
    [self.navigationController pushViewController:readerVC animated:YES];
    
    readerVC.toolBarItemDidSelected = ^(PRToolBarItemType type, BOOL selected) {
        NSLog(@"%ld --- %d", type, selected);
    };
    
    self.readerVC = readerVC;
}

- (void)showOpenBookOptionAlertWithBookModel:(PRBookModel *)book {
    
    BOOL hasUpdate = [PRBookDownloader checkBookUpdateWithBookID:book.book_id error:nil];
    
    if (book.isDownloaded) {
        
        if (hasUpdate) {
            
            [self showAlertWithMessage:@"选择需要进行的操作" firstButtonTitle:@"更新教材" secondButtonTitle:@"继续阅读" thirdButtonTitle:@"取消" firstHandle:^{
                [self downloadBookWithBookModel:book];
            } secondHandle:^{
                [self openBookWithModel:book];
            } thirdHandle:^{
                
            }];
            
        } else {
            
            [self openBookWithModel:book];
            
        }
        
    } else {
        
        [self showAlertWithMessage:@"选择需要进行的操作" firstButtonTitle:@"下载教材" secondButtonTitle:@"在线阅读" thirdButtonTitle:@"取消" firstHandle:^{
            [self downloadBookWithBookModel:book];
        } secondHandle:^{
            [self openBookWithModel:book];
        } thirdHandle:^{
            
        }];
        
    }
    
}


- (void)showAlertWithTitle:(NSString *)title
                   Message:(NSString *)message
             sureButtonTitle:(NSString *)sureTitle
           cancelButtonTitle:(NSString *)cancelTitle
                  sureHandle:(void (^ __nullable)(void))sureHandle
                cancelHandle:(void (^ __nullable)(void))cancelHandle {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sureHandle) { sureHandle(); }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandle) { cancelHandle(); }
    }];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showAlertWithMessage:(NSString *)message
             firstButtonTitle:(NSString *)firstTitle
           secondButtonTitle:(NSString *)secondTitle
                 thirdButtonTitle:(NSString *)thirdTitle
                  firstHandle:(void (^ __nullable)(void))firstHandle
                secondHandle:(void (^ __nullable)(void))secondHandle
                thirdHandle:(void (^ __nullable)(void))thirdHandle {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (firstHandle) { firstHandle(); }
    }];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:secondTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (secondHandle) { secondHandle(); }
    }];
    
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:thirdTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (thirdHandle) { thirdHandle(); }
    }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    
    [self presentViewController:alert animated:true completion:nil];
}


// MARK: - Status Bar

- (BOOL)prefersStatusBarHidden {
    return false;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end




