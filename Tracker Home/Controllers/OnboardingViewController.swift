//
//  OnboardingViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 05.02.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    let isLogin = AppSettingsStorage.shared
    
    let onboardingButtonText = NSLocalizedString("onboardingButtonText", comment: "Текст кнопки на экране онбоардинга")
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var pages: [UIViewController] = {
        //Первый экран
        let first = UIViewController()
        
        let firstBackgroundImage = UIImageView(image: UIImage(named: "OnboardingPage1"))
        firstBackgroundImage.contentMode = .scaleAspectFill
        firstBackgroundImage.frame = view.bounds
        first.view.addSubview(firstBackgroundImage)
        
        let firstTitle = UILabel()
        let onboardingTextOne = NSLocalizedString("onboardingTitleTextOne", comment: "Текст на экране онбоардинга #1")
        firstTitle.text = onboardingTextOne
        firstTitle.font = .systemFont(ofSize: 32, weight: .bold)
        firstTitle.numberOfLines = 2
        firstTitle.textAlignment = .center
        first.view.addSubview(firstTitle)
        firstTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let onboardingFirstButton = UIButton()
        onboardingFirstButton.backgroundColor = .udBlackDay
        onboardingFirstButton.setTitle(onboardingButtonText, for: .normal)
        onboardingFirstButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        onboardingFirstButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        onboardingFirstButton.layer.cornerRadius = 16
        onboardingFirstButton.translatesAutoresizingMaskIntoConstraints = false
        onboardingFirstButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        first.view.addSubview(onboardingFirstButton)
    
        //Второй экран
        let second = UIViewController()
        
        let secondBackgroundImage = UIImageView(image: UIImage(named: "OnboardingPage2"))
        secondBackgroundImage.contentMode = .scaleAspectFill
        secondBackgroundImage.frame = view.bounds
        second.view.addSubview(secondBackgroundImage)
        
        let secondTitle = UILabel()
        let onboardingTextTwo = NSLocalizedString("onboardingTitleTextTwo", comment: "Текст на экране онбоардинга #2")
        secondTitle.text = onboardingTextTwo
        secondTitle.font = .systemFont(ofSize: 32, weight: .bold)
        secondTitle.numberOfLines = 2
        secondTitle.textAlignment = .center
        second.view.addSubview(secondTitle)
        secondTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let onboardingSecondButton = UIButton()
        onboardingSecondButton.backgroundColor = .udBlackDay
        onboardingSecondButton.setTitle(onboardingButtonText, for: .normal)
        onboardingSecondButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        onboardingSecondButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        onboardingSecondButton.layer.cornerRadius = 16
        onboardingSecondButton.translatesAutoresizingMaskIntoConstraints = false
        onboardingSecondButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        second.view.addSubview(onboardingSecondButton)
        
        //констрейнты лейбла
        NSLayoutConstraint.activate([
            firstTitle.leadingAnchor.constraint(equalTo: first.view.leadingAnchor, constant: 16),
            firstTitle.trailingAnchor.constraint(equalTo: first.view.trailingAnchor, constant: -16),
            firstTitle.topAnchor.constraint(equalTo: first.view.safeAreaLayoutGuide.topAnchor, constant: 388),
            
            onboardingFirstButton.leadingAnchor.constraint(equalTo: first.view.leadingAnchor, constant: 20),
            onboardingFirstButton.trailingAnchor.constraint(equalTo: first.view.trailingAnchor, constant: -20),
            onboardingFirstButton.bottomAnchor.constraint(equalTo: first.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            secondTitle.leadingAnchor.constraint(equalTo: second.view.leadingAnchor, constant: 16),
            secondTitle.trailingAnchor.constraint(equalTo: second.view.trailingAnchor, constant: -16),
            secondTitle.topAnchor.constraint(equalTo: second.view.safeAreaLayoutGuide.topAnchor, constant: 388),
            
            onboardingSecondButton.leadingAnchor.constraint(equalTo: second.view.leadingAnchor, constant: 20),
            onboardingSecondButton.trailingAnchor.constraint(equalTo: second.view.trailingAnchor, constant: -20),
            onboardingSecondButton.bottomAnchor.constraint(equalTo: second.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            ])
        
        return [first, second]
    }()
    
    @objc
    private func buttonClicked() {
        let vc = MainTabBarController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        isLogin.isLogin(condition: true)
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .udBlackDay
        pageControl.pageIndicatorTintColor = .udGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        dataSource = self
        delegate = self
        
        //найдем в качестве текущего контроллера первый из этого массива
        if let firstPages = pages.first {
            setViewControllers([firstPages], direction: .forward, animated: true)
        }
    }
}

//MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    //Возвращаем предыдущий дочерний контролле
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { 
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return pages.last }
        return pages[previousIndex]
    }
    
    //Возвращаем следующий дочерний контроллер
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return pages.first }
        return pages[nextIndex]
    }
}

//MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first, let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
        
    }
}



