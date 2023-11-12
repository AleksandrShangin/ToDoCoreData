// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Categories {
    /// Delete Category
    internal static let delete = L10n.tr("Localizable", "categories.delete", fallback: "Delete Category")
    /// New Category
    internal static let new = L10n.tr("Localizable", "categories.new", fallback: "New Category")
    /// Rename Category
    internal static let rename = L10n.tr("Localizable", "categories.rename", fallback: "Rename Category")
    /// Organizer
    internal static let title = L10n.tr("Localizable", "categories.title", fallback: "Organizer")
  }
  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Error
    internal static let error = L10n.tr("Localizable", "common.error", fallback: "Error")
    /// Localizable.strings
    ///   ToDoCoreData
    /// 
    ///   Created by Alexander Shangin on 12.11.2023.
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
  }
  internal enum Project {
    /// Delete Project
    internal static let delete = L10n.tr("Localizable", "project.delete", fallback: "Delete Project")
    /// New Project
    internal static let new = L10n.tr("Localizable", "project.new", fallback: "New Project")
    /// Rename Project
    internal static let rename = L10n.tr("Localizable", "project.rename", fallback: "Rename Project")
  }
  internal enum Task {
    /// Add New Task
    internal static let addNew = L10n.tr("Localizable", "task.add-new", fallback: "Add New Task")
    /// Complete Task
    internal static let complete = L10n.tr("Localizable", "task.complete", fallback: "Complete Task")
    /// Delete Task
    internal static let delete = L10n.tr("Localizable", "task.delete", fallback: "Delete Task")
    /// New Task
    internal static let new = L10n.tr("Localizable", "task.new", fallback: "New Task")
    /// Rename Task
    internal static let rename = L10n.tr("Localizable", "task.rename", fallback: "Rename Task")
    /// Undo Complete
    internal static let undoComplete = L10n.tr("Localizable", "task.undo-complete", fallback: "Undo Complete")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
