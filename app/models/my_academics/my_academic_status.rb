module MyAcademics
  class MyAcademicStatus < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Concerns::AcademicRoles
    include Concerns::AcademicStatus

    def get_feed_internal
      response = HubEdos::AcademicStatus.new({user_id: @uid}).get
      if (academic_statuses = academic_statuses response )
        assign_roles(academic_statuses)
      end
      response
    end

    # Beware: roles may be used as a whitelist (to show certain info), a blacklist (to hide certain info),
    #  or as some combination of the two in custom logic.
    def assign_roles(academic_statuses)
      academic_statuses.each do |status|
        process_career(status)
        process_plans(status)
      end
    end

    def process_career(status)
      if (career = status.try(:[], 'studentCareer'))
        status['studentCareer'][:role] = career_based_role career
      end
    end

    def process_plans(status)
      if (plans = status.try(:[], 'studentPlans'))
        plans.each do |plan|
          if active? plan
            plan[:role] = plan_based_role plan
            if (program = plan.try(:[], 'academicPlan').try(:[], 'academicProgram'))
              plan['academicPlan']['academicProgram'][:role] = program_based_role program
            end
          end
        end
      end
    end

    def career_based_role(studentCareer)
      career_code = studentCareer.try(:[], 'academicCareer').try(:[], 'code')
      get_academic_career_role_code(career_code) if studentCareer
    end

    def plan_based_role(studentPlan)
      plan_code = studentPlan.try(:[], 'academicPlan').try(:[], 'plan').try(:[], 'code')
      get_academic_plan_role_code(plan_code) if studentPlan
    end

    def program_based_role(studentProgram)
      program_code = studentProgram.try(:[], 'program').try(:[], 'code')
      get_academic_program_role_code(program_code) if studentProgram
    end
  end
end
