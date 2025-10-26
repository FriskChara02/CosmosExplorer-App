//
//  SkyLiveViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftUI
import SwiftAA
import CoreLocation

class SkyLiveViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var planetData: [String: PlanetInfo] = [:]
    @Published var isLoading: Bool = true
    @Published var location: GeographicCoordinates = GeographicCoordinates(
        positivelyWestwardLongitude: Degree(106.7009),
        latitude: Degree(10.7769)
    ) // Default: Ho Chi Minh City
    
    private let locationManager = CLLocationManager()
    private let date = Date()
    
    // MARK: - List of celestial bodies
    private let planetClasses: [String: any CelestialBody.Type] = [
        "Sun": Sun.self,
        "Moon": Moon.self,
        "Mercury": Mercury.self,
        "Venus": Venus.self,
        "Mars": Mars.self,
        "Jupiter": Jupiter.self,
        "Saturn": Saturn.self,
        "Uranus": Uranus.self,
        "Neptune": Neptune.self
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        fetchData()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            fetchData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            location = GeographicCoordinates(
                positivelyWestwardLongitude: Degree(-loc.coordinate.longitude),
                latitude: Degree(loc.coordinate.latitude)
            )
            fetchData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        fetchData()
    }
    
    // MARK: - Fetch astronomical data
    func fetchData() {
        isLoading = true
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            var data: [String: PlanetInfo] = [:]
            let jd = JulianDay(self.date)
            let currentTime = DateFormatter.localizedString(from: self.date, dateStyle: .short, timeStyle: .short)
            
            let sun = Sun(julianDay: jd, highPrecision: true)
            let sunCoords = sun.equatorialCoordinates
            
            for (name, planetType) in self.planetClasses {
                let body = planetType.init(julianDay: jd, highPrecision: true)
                
                var riseStr = "—", transitStr = "—", setStr = "—"
                var altitudeStr = "—"
                let orbitalSpeed: String? = nil
                var events: [AstronomicalEvent] = []
                var dayLength: String? = nil
                var nightLength: String? = nil
                var seasons: [String]? = nil
                var moonPhase: String? = nil
                var nextMoonPhases: [String]? = nil
                
                // MARK: - Process celestial body data
                switch body {
                case let sun as Sun:
                    // Sun
                    let rts = sun.riseTransitSetTimes(for: self.location)
                    riseStr = rts.riseTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    transitStr = rts.transitTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    setStr = rts.setTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    
                    let coords = sun.equatorialCoordinates
                    altitudeStr = String(format: "%.2f°", coords.declination.value)
                    
                    // Tính dayLength và nightLength
                    if let rise = rts.riseTime?.date, let set = rts.setTime?.date {
                        let dayLengthHours = set.timeIntervalSince(rise) / 3600 // Giờ
                        dayLength = String(format: "%.2f %@", dayLengthHours, LanguageManager.current.string("hours"))
                        
                        // Tính nightLength (từ set đến rise ngày tiếp theo)
                        let nextDayJD = JulianDay(jd.value + 1)
                        let nextDaySun = Sun(julianDay: nextDayJD, highPrecision: true)
                        let nextRts = nextDaySun.riseTransitSetTimes(for: self.location)
                        if let nextRise = nextRts.riseTime?.date {
                            let nightLengthHours = nextRise.timeIntervalSince(set) / 3600 // Giờ
                            nightLength = String(format: "%.2f %@", nightLengthHours, LanguageManager.current.string("hours"))
                        }
                    }
                    
                    // Tính mùa (seasons) dựa trên tháng và vĩ độ
                    let month = Calendar.current.component(.month, from: self.date)
                    let latitude = self.location.latitude.value
                    let season: String
                    if latitude > 0 { // Bắc bán cầu
                        switch month {
                        case 3...5: season = LanguageManager.current.string("Spring")
                        case 6...8: season = LanguageManager.current.string("Summer")
                        case 9...11: season = LanguageManager.current.string("Autumn")
                        default: season = LanguageManager.current.string("Winter")
                        }
                    } else { // Nam bán cầu
                        switch month {
                        case 3...5: season = LanguageManager.current.string("Autumn")
                        case 6...8: season = LanguageManager.current.string("Winter")
                        case 9...11: season = LanguageManager.current.string("Spring")
                        default: season = LanguageManager.current.string("Summer")
                        }
                    }
                    seasons = [season]
                    
                case let moon as Moon:
                    // Moon
                    let rts = moon.riseTransitSetTimes(for: self.location)
                    riseStr = rts.riseTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    transitStr = rts.transitTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    setStr = rts.setTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    
                    let currentJulianDay = JulianDay(Date())
                    let equCoords = moon.equatorialCoordinates
                    let horizontalCoords = equCoords.makeHorizontalCoordinates(for: self.location, at: currentJulianDay)
                    let alt = horizontalCoords.altitude
                    altitudeStr = String(format: "%.2f°", alt.value)
                    
                    // Moon phase
                    let illumination = moon.illuminatedFraction()
                    let phaseAngle = moon.phaseAngle().value
                    let phaseDescription: String
                    switch illumination {
                    case 0.0..<0.03:
                        phaseDescription = LanguageManager.current.string("New Moon")
                    case 0.03..<0.25:
                        phaseDescription = LanguageManager.current.string("Waxing Crescent")
                    case 0.25..<0.49:
                        phaseDescription = LanguageManager.current.string("First Quarter")
                    case 0.49..<0.51:
                        phaseDescription = LanguageManager.current.string("Full Moon")
                    case 0.51..<0.75:
                        phaseDescription = LanguageManager.current.string("Last Quarter")
                    default:
                        phaseDescription = LanguageManager.current.string("Waning Crescent")
                    }
                    moonPhase = phaseDescription
                    
                    let phaseCycle = 29.53 // Chu kỳ trung bình của Mặt Trăng (ngày)
                    let currentJD = jd.value
                    let phases = [
                        (name: "New Moon", illumination: 0.0),
                        (name: "First Quarter", illumination: 0.25),
                        (name: "Full Moon", illumination: 0.5),
                        (name: "Last Quarter", illumination: 0.75)
                    ]
                    nextMoonPhases = phases.map { phase in
                        let targetJD = currentJD + phaseCycle * (phase.illumination - illumination)
                        let targetDate = JulianDay(targetJD).date
                        return "\(LanguageManager.current.string(phase.name)): \(targetDate.formatted(.dateTime.day().month().year()))"
                    }
                    
                    // Astronomical events
                    events = [
                        AstronomicalEvent(
                            name: LanguageManager.current.string("Moon Phase"),
                            date: self.date.formatted(.dateTime.day().month().year()),
                            description: phaseDescription
                        ),
                        AstronomicalEvent(
                            name: LanguageManager.current.string("Phase Angle"),
                            date: self.date.formatted(.dateTime.day().month().year()),
                            description: String(format: "%.1f°", phaseAngle)
                        ),
                        AstronomicalEvent(
                            name: LanguageManager.current.string("Illuminated Fraction"),
                            date: self.date.formatted(.dateTime.day().month().year()),
                            description: String(format: "%.1f%%", illumination * 100)
                        )
                    ]
                    
                case let planet as Planet:
                    // Planets
                    let rts = planet.riseTransitSetTimes(for: self.location)
                    riseStr = rts.riseTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    transitStr = rts.transitTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    setStr = rts.setTime?.date.formatted(.dateTime.hour().minute()) ?? "—"
                    
                    let currentJulianDay = JulianDay(Date())
                    let equCoords = planet.equatorialCoordinates
                    let coords = equCoords.makeHorizontalCoordinates(for: self.location, at: currentJulianDay)
                    altitudeStr = String(format: "%.2f°", coords.altitude.value)
                    
                    if name == "Venus" || name == "Mercury" {
                        let planetCoords = planet.equatorialCoordinates
                        let deltaRA = (planetCoords.rightAscension - sunCoords.rightAscension).inRadians.value
                        let delta1 = planetCoords.declination.inRadians.value
                        let delta2 = sunCoords.declination.inRadians.value
                        
                        let cosTheta = sin(delta1) * sin(delta2) + cos(delta1) * cos(delta2) * cos(deltaRA)
                        let theta = acos(cosTheta)
                        let elongation = theta * (180.0 / .pi)
                        
                        events.append(AstronomicalEvent(
                            name: LanguageManager.current.string("Elongation"),
                            date: self.date.formatted(.dateTime.day().month().year()),
                            description: String(format: "%@: %.1f°", LanguageManager.current.string("Elongation Angle"), elongation)
                        ))
                    }
                    
                    if name == "Mars" {
                        let oppJD = planet.opposition()
                        if abs(oppJD.value - jd.value) < 3 {
                            events.append(AstronomicalEvent(
                                name: LanguageManager.current.string("Opposition"),
                                date: oppJD.date.formatted(.dateTime.day().month().year()),
                                description: LanguageManager.current.string("Opposition Description")
                            ))
                        }
                    }
                    
                default:
                    break
                }
                
                // MARK: - Assign data
                data[name] = PlanetInfo(
                    name: name,
                    rise: riseStr,
                    transit: transitStr,
                    set: setStr,
                    altitude: altitudeStr,
                    currentTime: currentTime,
                    orbitalSpeed: orbitalSpeed,
                    dayLength: dayLength,
                    nightLength: nightLength,
                    moonPhase: moonPhase,
                    nextMoonPhases: nextMoonPhases,
                    seasons: seasons,
                    astronomicalEvents: events
                )
            }
            
            DispatchQueue.main.async {
                self.planetData = data
                self.isLoading = false
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
    }
}

// MARK: - Helper
extension Hour {
    var string: String {
        let h = Int(value)
        let m = Int((value - Double(h)) * 60)
        return String(format: "%02d:%02d", h, m)
    }
}
