//
//  CNStretchyCollectionViewController.m
//  CNSpringCollectionView
//
//  Created by Christian Noon on 11/3/13.
//  Copyright (c) 2013 NoonDev. All rights reserved.
//

#import "CNStretchyCollectionViewController.h"
#import "CNStretchyCollectionViewFlowLayout.h"

@implementation CNStretchyCollectionViewController

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
	// Register the cell
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];

	// Tweak out the content insets
	CNStretchyCollectionViewFlowLayout *layout = (CNStretchyCollectionViewFlowLayout *) self.collectionViewLayout;
	self.collectionView.contentInset = layout.bufferedContentInsets;

	// Set the delegate for the collection view
	self.collectionView.delegate = self;
	self.collectionView.clipsToBounds = NO;

	// Customize the appearance of the collection view
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	if ([indexPath row] % 2 == 0)
		cell.backgroundColor = [UIColor orangeColor];
	else
		cell.backgroundColor = [UIColor blueColor];

	return cell;
}

@end
